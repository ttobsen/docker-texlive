FROM ubuntu:18.04
LABEL maintainer="Tobias Baumann <tobias.baumann@elpra.de>"

WORKDIR /opt

RUN apt-get update && \
    apt-get -y install nano perl-modules libterm-readline-perl-perl imagemagick wget file \
                       aspell aspell-en aspell-de librsvg2-bin

RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar -xvf install-tl-unx.tar.gz --strip-components=1
    
COPY texlive.profile /opt/texlive.profile

RUN ./install-tl --profile=texlive.profile

ENV PATH="/opt/texlive/2018/bin/x86_64-linux:${PATH}"

RUN tlmgr install merriweather fontaxes mweights varwidth multirow nag units \
    tabu ifplatform xstring csquotes textpos draftwatermark everypage enumitem
