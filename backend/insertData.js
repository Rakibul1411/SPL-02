// Correct import statement
import { MongoClient } from 'mongodb';

async function main() {
  const uri = 'mongodb+srv://hasnain:1408@spl.snqpb.mongodb.net/'; // MongoDB connection URI
  const client = new MongoClient(uri);

  try {
    await client.connect();
    const database = client.db('SPLDB');
    const collection = database.collection('incentiveandratings');

    const data = {
      _id: '123411',
      workerId: '67c57d873fc3b614f6b822ff',
      taskId: 'task456',
      amount: 100.0,
      issuedAt: new Date('2023-10-01T12:00:00Z'),
      rating: 5,
      feedback: 'Great work!',
      ratedBy: 'rater789',
      createdAt: new Date('2023-10-01T12:30:00Z'),
    };

    const result = await collection.insertOne(data);
    console.log('Data inserted with _id:', result.insertedId);
  } finally {
    await client.close();
  }
}

main().catch(console.error);