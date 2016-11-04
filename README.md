# Social Words

### Social Words determines the size of a word's social network.

A word's social network consists of any other words that have a Levenshtein distance of 1 from the test word,
and those word's social networks, and so on for all the words in the word list. The `data.txt` file contains
test words (the social network sizes to be determined) and the word list (words of which the networks will
consist), separated by the line `END OF INPUT`. This application will calculate the size of the social networks
for each test word and print the results to the terminal.


## Run
This application requires [Elixir](http://elixir-lang.org) to run.

run `$ elixir social_words.exs`
