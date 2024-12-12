import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

from haystack import Document
from haystack.document_stores.in_memory import InMemoryDocumentStore
#from haystack.components.builders.prompt_builder import PromptBuilder
#from haystack.components.embedders.sentence_transformers_text_embedder import SentenceTransformersTextEmbedder

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


# Load documents into memory
document_store = InMemoryDocumentStore()
with open('python/data/documents.txt') as txt_file:
    document_store.write_documents([Document(content=str) for str in txt_file.readlines()])

# Quantize Model
quant = BitsAndBytesConfig(load_in_8bit=quant_8bit)

# Initialize model and text generator   
model = models.transformers(checkpoint, device='cuda', model_kwargs={"quantization_config":quant})
sampler = samplers.MultinomialSampler(temperature=temperature)
query_generator = generate.text(model, sampler)
print(f'memory used: {model.model.get_memory_footprint()//1e3} KB')

# Model interface functions
def completion(prompt : str, choices : list[str]) -> str:
    generator = generate.choice(model, choices, sampler)
    query = f"""{prompt}"""
    return generator(query)


def question(prompt : str) -> str:
    query = f"""<|system|>
    You are a question answering assistant. Answer the question in a single sentence or line.<|end|>
    <|question|>
    {prompt}<|end|>
    <|answer|>"""

    return query_generator(query, max_tokens=max_tokens, stop_at=['.', '!'])