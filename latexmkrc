# Run texcount before each compilation to update the word count
system("texcount -utf8 -sum -1 -q main.tex > wordcount.tex 2>/dev/null || echo 'N/A' > wordcount.tex");
