---
layout: post
title: Meeting Call Transcript Summarization
summary: Domain adapted Abstractive Summarization of meeting call transcript.
featured-img: call-summarization/call-summarization-card
categories: NLP
---

Recently, I worked on a research use case based on natural language generation (NLG) in which the goal was to generate an speaker specific abstractive summary in a controlled manner. As we know that when we talk about text summarization, there are two fundamental approaches i.e **Extractive Summarization** in which idea is to identify important sections of the call transcript with respect to each speaker and generating them verbatim producing a subset of the sentences from the original text; while in **Abstractive Summarization** idea is to generate a short and concise summary that captures the salient ideas of the source text. The generated summaries potentially contain new phrases and sentences that may not appear in the source text. So abstractive summarization is more advanced as well as feels more human-like. Also, this blog post is a part of series of blog posts in which I will cover everything in detail and specifically how we solved this problem. 

## Problem Statement
Let's now deep dive into problem definition in detail:

Given a call audio between *Agent Speaker* and *Customer Speaker* (or multiple speaker), goal is to generate a domain adapted abstractive summary such that it should be concise and should capture the important facts corresponding each speaker in the call. 

Mathematically, we can formulate problem of domain adapted meeting call summarization as follows. The input to our AI system consists of meeting call transcripts X and S unique speakers (in our case it's 2) and we have N meetings in total. So, the transcripts are X = {X<sub>1</sub>, X<sub>2</sub>, ...X<sub>N</sub>}. Here each transcript consists of multiple turns, where each turn is the utterance of a speaker. 
Thus, X<sub>i</sub> = {(s<sub>1</sub>, u<sub>1</sub>),(s<sub>2</sub>, u<sub>2</sub>), ...,(s<sub>Li</sub>, u<sub>Li</sub>)}, where s<sub>j</sub> ∈ S, 1 ≤ j ≤ Li, is a speaker and u<sub>j</sub> = (w<sub>1</sub>, ..., w<sub>lj</sub>) is the tokenized utterance for speaker s<sub>j</sub>. 

And For each meeting X<sub>i</sub>, we have the following labels:

a) <ins>Human-labelled speaker tag</ins> for each speaker utterances of the ith meeting as T<sub>i</sub>, T<sub>i</sub> = {(s<sub>1</sub>, u<sub>1</sub>, t<sub>1</sub>),(s<sub>2</sub>, u<sub>2</sub>, t<sub>2</sub>), ...,(s<sub>Li</sub>, u<sub>Li</sub>, t<sub>Li</sub>)}, where t<sub>j</sub> ∈ {Agent, Customer}, 1 ≤ j ≤ Li is a speaker utterance being labelled as either agent or customer

d) <ins>Human-labelled category</ins> of the ith meeting as c<sub>i</sub>, C={c<sub>1</sub>, c<sub>2</sub>...c<sub>K</sub>}, where c<sub>i</sub> ∈ C, K = Total number of categories

c) <ins>Human-marked important/unimportant utterances</ins> for each speaker of the ith meeting as I<sub>i</sub>, I<sub>i</sub> = {(s<sub>1</sub>, u<sub>1</sub>, z<sub>1</sub>),(s<sub>2</sub>, u<sub>2</sub>, z<sub>2</sub>), ...,(s<sub>Li</sub>, u<sub>Li</sub>, z<sub>Li</sub>)}, where z<sub>j</sub> ∈ {0,1}, 1 ≤ j ≤ Li is a speaker utterance being marked as important or not, 0 = UnImportant, 1 = Important

d) <ins>Human-labelled Summary</ins> of ith meeting as Y<sub>i</sub> for both the speakers i.e Y<sub>i</sub> = {Y<sub>iA</sub>, Y<sub>iC</sub>}, where Y<sub>iA</sub> = (w'<sub>1</sub>, ..., w'<sub>A</sub>) is a sequence of tokens for agent and Y<sub>iC</sub> = (w''<sub>1</sub>, ..., w''<sub>C</sub>) is a sequence of tokens for customer

(Add diagram for sample data)

## How its helpful ?

As we know that customer support is a crucial part of every industry. And by transforming customer service interactions, AI-powered digital solutions are prepared to improve every aspect of business.

The solution on which I worked was specifically build for a Travel and Hospitality industry.

* Often in Travel and Hospitality industries, Guest Relations department receives a large number of calls from customers asking queries regarding booking, cancellations, billing etc. and a team of agents is expected to address the customer queries and take notes from the conversation with the customer. 

* This manual process of taking notes after the call takes up a lot of time of the Guest Relations agents and the accuracy of the same is also quite low. There is also a factor of subjectivity that comes in. 
  
* These notes by agent gathers important facts like check-In date, check-Out date, booking amount, customer sentiment, hotel location, hotel brand etc. which can be further used for analysis to get insights like % of positive customer sentiment in the call, % of hotel brand usually booked by customer etc. on weekly or monthly basis
  
* AI powered solution can be helpful to either automate this process or assist the agent by generating a agent and customer summary that summarizes above important facts immediately as soon as the call ends. 
  

## Challenges

Now, that you have understanding of how this problem is kind of a big deal. But when we started working on this usecase, one thing was sure that we can't just directly use some blackbox model to generate these summaries. Below are some of th important challenges that our solution tries to address to some extent

1. <ins>Long nature of transcripts:</ins> Since, meeting call transcripts are always long which means that usual conversation would contain around 2000-4000 tokens. So, How we can incoperate this long nature of the transcript while designing the architecture.
   
2. <ins>Hierarchical structure of transcripts:</ins> Also, meeting call transcripts always follow a hierarchical structure which means that 
meeting consists of utterances from different speakers and forms a natural multi-turn hierarchy with each speaker having a fixed style of talking. So, How can we leverage this a hierarchical structure while designing the architecture.
    
3. <ins>Different Style:</ins> Semantic structure and styles of meeting call transcripts are quite different from articles and conversations.
   
4. <ins>Generative Repetitions:</ins> Often generative models have this common problem of repetions due to which it predicted summary contains repetative facts. So, How can we avoid these repetitions.
   
5. <ins>Generative Hallucinations:</ins> Generative models also have a problem of hallucinations due to which it predicted summary contains facts that are not even mentioned in the actual input transcript. So, How can we generate in a controlled manner.
   
6. <ins>Incorrect Gender</ins>: If human-labelled summary contains sentences referring speaker as third person (he or she) then, it can be possible that generated summary would contain wrong gender. So, How do we identify gender of each speaker from the original audio call and incoporate that to correct the gender in final prediction.
   
7. <ins>Few shot settings</ins>: If we don't have enough human-labelled data. So, how can we make our system learn in few shot settings

## Previous Research Work

Most of the early abstractive approaches were based on either sentence compression or templates to generate summaries. But in the recent years, we have seen a very significant advancements, thanks to the emergence of neural sequence-to-sequence models. Although, previously sequence-to-sequence models were based on reccurent neural networks which actually set a good benchmark and was considered as state of the art for a long time but by recently, we found that how using Transformers architecture further pushed this benchmark.

Also, initially the area was mostly concerned with headline generation, followed by multi-sentence summarization on news databases (like CNN/DailyMail corpus).
Further improvements include pointer generator networks which learns whether to generate words or to copy them from the source; attention over time; and hybrid learning objectives.

During the early days of the usecase, we tried several methods just to check the baseline before we finalized the final solution. Though, these baseline methods  were trained on above (CNN/DailyMail corpus) data like pointer generator network which gave poor results and was hallucinating.


![Pointer-Generator-Network]({{ site.url }}{{ site.baseurl }}/assets/img/posts/call-summarization/pointer-generator-network.png)

Above is the architecture of pointer generator network, 


![HMNet]({{ site.url }}{{ site.baseurl }}/assets/img/posts/call-summarization/hmnet.png)

## Solution Architecture

## Results

## Conclusion

## References
- All the research papers
   