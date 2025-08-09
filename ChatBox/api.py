from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from ChatBot import MedicinalPlantBot
import uvicorn

app = FastAPI(title="Medicinal Plant ChatBot API")

# Thêm CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Khởi tạo ChatBot
try:
    bot = MedicinalPlantBot()
except Exception as e:
    print(f"Error initializing ChatBot: {str(e)}")
    bot = None

class Question(BaseModel):
    question: str

@app.get("/chat")
async def health_check():
    return {"status": "healthy"}

@app.post("/chat/ask")
async def ask_question(question: Question):
    if bot is None:
        raise HTTPException(status_code=500, detail="ChatBot not initialized properly")
    
    try:
        answer = bot.ask(question.question)
        return {"answer": answer}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=2000) 