import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import OpenAI from 'openai';

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json());

// 🔒 Coloque sua chave da OpenAI aqui
const openai = new OpenAI({
  apiKey: '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', // substitua pela sua chave secreta
});

app.post('/interpretar', async (req, res) => {
  const { sonho } = req.body;

  if (!sonho) {
    return res.status(400).json({ error: 'Sonho é obrigatório.' });
  }

  try {
    const respostaIA = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: 'Você é um especialista em interpretação de sonhos, com empatia e sabedoria.' },
        { role: 'user', content: `Interprete este sonho: ${sonho}` },
      ],
    });

    const resposta = respostaIA.choices[0].message.content;
    res.json({ resposta });
  } catch (error) {
    console.error('Erro ao chamar a OpenAI:', error);
    res.status(500).json({ error: 'Erro ao interpretar o sonho.' });
  }
});

app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});
