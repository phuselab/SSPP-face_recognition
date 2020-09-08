# Single sample face recognition by sparse recovery of deep-learned LDA features

***Matteo Bodini¹, Alessandro D’Amelio¹, Giuliano Grossi¹, Raffaella Lanzarotti¹, Jianyi Lin²***  
¹ [PHuSe Lab](https://phuselab.di.unimi.it) - Dipartimento di Informatica, Università degli Studi di Milano  
² Department of Mathematics, Khalifa University of Science and Technology  

**Paper** *Bodini, M., D’Amelio, A., Grossi, G., Lanzarotti, R., & Lin, J. (2018, September). Single sample face recognition by sparse recovery of deep-learned lda features. In International Conference on Advanced Concepts for Intelligent Vision Systems (pp. 297-308). Springer, Cham.*

https://link.springer.com/chapter/10.1007/978-3-030-01449-0_25

## Usage
Open Matlab and run the script

```
demo.m
```

This will automatically load the data file, which contains the preprocessed images of a subset (50 subjects) of the Labeled Faces 
in the Wild Dataset (LFW). The 50 subjects were randomly choosen from the 1680 that have at least 2 images. Two images for each 
subject were randomly chosen: one for gallery and one for testing.


### Reference

If you use this code or data, please cite the paper:
```
@inproceedings{bodini2018single,
  title={Single sample face recognition by sparse recovery of deep-learned lda features},
  author={Bodini, Matteo and D’Amelio, Alessandro and Grossi, Giuliano and Lanzarotti, Raffaella and Lin, Jianyi},
  booktitle={International Conference on Advanced Concepts for Intelligent Vision Systems},
  pages={297--308},
  year={2018},
  organization={Springer}
}
```
