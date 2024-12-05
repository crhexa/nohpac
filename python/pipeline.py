from haystack import Pipeline, Document
from haystack.document_stores.in_memory import InMemoryDocumentStore
#from haystack.components.builders.prompt_builder import PromptBuilder
#from haystack.components.embedders.sentence_transformers_text_embedder import SentenceTransformersTextEmbedder

from outlines import models, generate, samplers
from torch import bfloat16
import json

# Load model config
checkpoint = ''
with open('python/data/config.json') as json_config:
    config = json.load(json_config)
    checkpoint = config['checkpoint']
    temperature = config['temperature']


# Load documents into memory
document_store = InMemoryDocumentStore()
with open('python/data/documents.txt') as txt_file:
    document_store.write_documents([Document(content=str) for str in txt_file.readlines()])


# Initialize model and text generator   
model = models.transformers(checkpoint, device='cuda', model_kwargs={"torch_dtype":bfloat16})
sampler = samplers.MultinomialSampler(temperature=temperature)
query_generator = generate.text(model, sampler)


# Model interface functions
def completion(prompt : str, choices : list[str]) -> str:
    generator = generate.choice(model, choices, sampler)
    return generator(prompt)


def question(prompt : str) -> str:
    return query_generator(prompt)