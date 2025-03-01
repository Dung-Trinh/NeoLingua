![logoAndText](https://github.com/user-attachments/assets/7bf261e4-a1ca-499f-a4b6-4220334b5793)

# NeoLingua
This iOS app is a prototype developed as part of a master thesis to explore the use of generative AI for the dynamic creation of personalized learning content in the field of Mobile-Assisted-Language Learning (MALL). In addition, the use of local and image-based contexts was included to create realistic and meaningful learning content.

## Features
* **Context-based-Learning:** It is possible to enter a prompt or upload an image to set the context to create specific learning content
* **Multimodal generation of learning content:** The following exercises have been created to practise language skills: Vocabulary exercise, Listening Comprehension and a conversation simulation with an assistant
* **Interactive error correction and feedback:** To support the learning process
* **Integration of gamification aspects:** Designed to make learning fun
* **Scavenger Hunt:** It is a game in which the player has to complete various learning tasks at certain locations, depending on the user's location. Users must move closer to the location in order to unlock the tasks. When all tasks have been completed, the user receives a hint that refers to a specific object which the user must take a photo of.
* **SnapVocabulary:** Interactive guessing game where you have to guess vocabulary on the picture and an AI assistant checks the input

## Preview

## Technologies
* **Integration of Assistants API (OpenAI):**
  - Content created by customized AI assistants
  - Dynamic generation and validation of learning content
  - Providing personalized feedback and error corrections
  - Use of Speech API for the TTS function
 
* **Firebase integration:**
  - **Firebase Auth**: For the administration and authentication of users
  - **Firestore (NoSQL)**: For storing various objects and user data
  - **Firebase Storage**: For storing user-specific images

* **Cloud Functions:** To request data from the Google Places API and to pass this to the Scavenger Hunt assistant to create a scavenger hunt based on the data.
