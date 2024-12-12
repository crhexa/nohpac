import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

from haystack import Document, Pipeline
from haystack.document_stores.in_memory import InMemoryDocumentStore
from haystack.components.embedders import SentenceTransformersTextEmbedder, SentenceTransformersDocumentEmbedder
from haystack.components.retrievers import InMemoryEmbeddingRetriever

from transformers import BitsAndBytesConfig
from outlines import models, generate, samplers
from torch import bfloat16
import json


# Load model config
checkpoint = ''
with open('python/data/config.json') as json_config:
    config = json.load(json_config)
    checkpoint = config['checkpoint']
    temperature = config['temperature']
    max_tokens = config['max_tokens']
    quant_8bit = config['quant_8bit']
    embed_model = config['embed_model']
    rel_threshold = config['embed_relevance_threshold']


# Initialize document store
document_store = InMemoryDocumentStore(embedding_similarity_function="cosine")
document_embedder = SentenceTransformersDocumentEmbedder(model=embed_model)
document_embedder.warm_up()

# Setup RAG pipeline
query_pipeline = Pipeline()
query_pipeline.add_component("text_embedder", SentenceTransformersTextEmbedder(model=embed_model))
query_pipeline.add_component("retriever", InMemoryEmbeddingRetriever(document_store=document_store))
query_pipeline.connect("text_embedder.embedding", "retriever.query_embedding")

# Insert document embeddings into store
with open('python/data/documents.txt') as txt_file:
    document_store.write_documents(
        document_embedder.run(
            [Document(content=str) for str in txt_file.readlines()]
        )['documents']
    )

# Quantize Model
if quant_8bit:
    mkwargs = {"quantization_config": BitsAndBytesConfig(load_in_8bit=True)}
else:
    mkwargs = {"torch_dtype": bfloat16}

# Initialize model and text generator
model = models.transformers(checkpoint, device='cuda', model_kwargs=mkwargs)
sampler = samplers.MultinomialSampler(temperature=temperature)
query_generator = generate.text(model, sampler)

# Query document retriever
def retrieve(query : str) -> str:
    relevant = query_pipeline.run({"text_embedder": {"text": query}})['retriever']['documents'][0]
    if relevant.score > rel_threshold:
        return f'{relevant.content}\n'
    else:
        return ''

# Model interface functions
def completion(prompt : str, choices : list[str]) -> str:
    generator = generate.choice(model, choices, sampler)
    query = f"""{retrieve(prompt)}{prompt}"""
    return generator(query)

def question(prompt : str) -> str:
    query = f"""<|system|>You are a question answering assistant. Answer the question in a single sentence.<|end|>
    {retrieve(prompt)}<|question|>{prompt}<|end|>
    <|answer|>"""
    response = query_generator(query, max_tokens=max_tokens, stop_at=['.', '!', '<|'])
    return response.removesuffix('<|')


# Model info
def get_memory() -> int:
    return model.model.get_memory_footprint()