
## Disclaimer ⚠

Since this work was published as our master's thesis, Patrick has continued to work on the [`deepvar`](https://github.com/pat-alt/deepvars) package. Among other things, he has found a bug in the original code, which has produced erroneous results for the test set in Table 1 of the paper. Since that bug has been removed from the package, that part of Table 1 can no longer be reproduced with the current package version (thanks to Hannes Osterchrist for flagging). In any case that part of the empirical exercise was somewhat flawed and will be removed (look-ahead bias). We have since moved to a rolling-window framework to assess the forecasting performance of our models (currently Figure 3 in the paper). We all have very limited bandwidth to continue work on this project at the moment, but please be advised that we very much consider this a work-in-progress, rather than a finished product. 

## Deep Vector Autoregression for Macroeconomic Data

This repository contains all the code for Altmeyer, Agusti, and
Vidal-Quadras Costa (2021). This research project started off as a
master’s thesis project, but has since been carried forward and accepted
for a poster presentation at the [NeurIPS 2021 MLECON
Workshop](https://nips.cc/Conferences/2021/ScheduleMultitrack?event=21847).
It is worth flagging that we still consider this very much a
work-in-progress - both the research and the companion package. We
therefore very much welcome any feedback, suggestions and comments.

For comments regarding the research and methodology, please [open an
issue](https://github.com/pat-alt/deepvarsMacro/issues) in this
repository. For any concerns regarding the companion package please open
an issue [here](https://github.com/pat-alt/deepvars/issues).

### Paper Abstract

*Vector Autoregression is a popular choice for forecasting time series
data. Due to its simplicity and success at modelling monetary economic
indicators VAR has become a standard tool for central bankers to
construct economic forecasts. A crucial assumption underlying the
conventional VAR is that interactions between variables through time can
be modelled linearly. We propose Deep VAR: a novel approach towards VAR
that leverages the power of deep learning in order to model non-linear
relatonships. By modelling each equation of the VAR system as a deep
neural network, our proposed extension outperforms its conventional
benchmark in terms of in-sample fit, out-of-sample fit and point
forecasting accuracy. In particular, we find that the Deep VAR is able
to better capture the structural economic changes during periods of
uncertainty and recession. By staying methodologically as close as
possible to the original benchmark, we hope that our approach is more
likely to find acceptance in the economics domain.*

## Pointers

A few useful pointers:

-   At a glance: NeurIPS 2021 [poster](poster/neurips.pdf) and [video
    presentation](https://www.youtube.com/watch?v=YRfwsZWf8mI&t=45s).
-   More detailed [poster](poster/poster.pdf).
-   Even more detailed [slides](presentation/presentation.pdf).
-   Full detail: [paper](paper/paper.pdf).
-   Code: [R Package](https://github.com/pat-alt/deepvars).

## Citation

Please cite our paper as follows:

    @article{altmeyer2021deep,
        author = {Altmeyer, Patrick and Agusti, Marc and Vidal-Quadras Costa, Ignacio},
        date-added = {2021-09-23 13:33:59 +0200},
        date-modified = {2021-11-30 16:33:49 +0100},
        title = {Deep Vector Autoregression for Macroeconomic Data},
        url = {https://thevoice.bse.eu/wp-content/uploads/2021/07/ds21-project-agusti-et-al.pdf},
        year = {2021}
    }

Please cite the companion package as follows:

    @software{Altmeyer_deepvars_Deep_Vector_2021,
      author = {Altmeyer, Patrick},
      month = {12},
      title = {{deepvars: Deep Vector Autoregression}},
      url = {https://github.com/pat-alt/deepvars},
      version = {0.1.0},
      year = {2021}
    }
