# MLPerf Inference - Object Detection - ONNX

This Python implementation runs ONNX models for Object Detection.
Currently, it only supports two models operating on the COCO 2017 validation dataset:
- SSD-ResNet34 (used in the v0.5-2.0 rounds).
- RetinaNet (used from the v2.1 round on the Open Images dataset; finetuned on the COCO dataset by Krai).

## Prerequisites

This workflow is designed to showcase the `axs` workflow management system.
So the only prerequisite from the user's point of view is a sufficiently fresh version of `axs` system.

<details><pre>
git clone https://github.com/krai/axs
</pre></details>

The dependencies of various components (on Python code and external utilities) as well as interdependencies of the workflow's main components (original dataset, preprocessed dataset, model and its parameters) have been described in `axs`'s internal language to achieve the fullest automation we could.

Please note that due to this automation (automatic recursive installation of all dependent components) the external timing of the initial runs (when new components have to be downloaded and/or installed) may not be very useful. The internal timing as measured by the LoadGen API should be trusted instead, which is not affected by these changes in external infrastructure.


## Initial clean-up (optional)

In some cases it may be desirable to "start from a clean slate" - i.e. clean up all the cached `axs` entries,
which includes the model with weights, the original COCO dataset and its resized versions
(different models need different resizing resolutions), as well as all the necessary Python packages.

On the other hand, since all those components may take considerable time to be installed, we do not recommend cleaning up between individual runs.
The entry cache is there for a reason.

The following command effectively wipes off hours of downloading, compilation and/or installation:
```
axs work_collection , remove
```


## Performing a short Accuracy run (specifying the number of samples to run on)

The following test run will trigger downloading and installation of the necessary Python packages, the default model (SSD-ResNet34), the original COCO dataset and a short partial resized subset of 20 images:
```
axs byquery loadgen_output,detected_coco,framework=onnx,loadgen_dataset_size=20 , get mAP
```
The mAP value should be printed after a succesful run.


## Performing a short Accuracy run (specifying the model)

The following test run will trigger (in addition to the above) downloading and installation of the RetinaNet model:
```
axs byquery loadgen_output,detected_coco,framework=onnx,loadgen_dataset_size=20,model_name=retinanet , get mAP
```
The mAP value should be printed after a succesful run.


## Benchmarking SSD-ResNet34 model in the Accuracy mode

The following command will trigger (in addition to the above) resizing of the whole COCO validation dataset of 5,000 images to the 1200x1200 resolution used by the SSD-ResNet34 model and will run on the whole dataset. Please note that depending on whether both the hardware and the software supports running on the GPU, the run may be performed either on the GPU or on the CPU.
(There are ways to constrain this to the CPU only.)
```
time axs byquery loadgen_output,detected_coco,framework=onnx,model_name=ssd_resnet34,loadgen_dataset_size=5000,loadgen_buffer_size=100 , get mAP
```
The mAP value and running time should be printed after a succesful run.
<details><pre>
...
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.200
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.381
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.184
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.118
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.258
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.233
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.200
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.321
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.344
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.174
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.407
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.416
mAP=19.973%

real    8m7.772s
</pre></details>


## Benchmarking SSD-ResNet34 model in the Performance mode

Two important changes for performance mode should be taken into account:
1. There is no way to measure mAP (LoadGen's constraint)
2. You need to "guess" the `loadgen_target_qps` parameter, from which the testing regime will be generated in order to measure the actual QPS.

So `TargetQPS` is the input, whereas `QPS` is the output of this benchmark:
```
axs byquery loadgen_output,detected_coco,framework=onnx,model_name=ssd_resnet34,loadgen_dataset_size=5000,loadgen_buffer_size=100,loadgen_mode=PerformanceOnly,loadgen_target_qps=32,verbosity=1 , dig summary.Samples_per_second

29.1735
```


## Benchmarking RetinaNet_COCO model in the Accuracy mode

The following command will trigger (in addition to the above) resizing of the whole COCO validation dataset of 5,000 images to the 800x800 resolution used by the RetinaNet_COCO model and will run on the whole dataset. Please note that depending on whether both the hardware and the software supports running on the GPU, the run may be performed either on the GPU or on the CPU.
(There are ways to constrain this to the CPU only.)
```
time axs byquery loadgen_output,detected_coco,framework=onnx,model_name=retinanet,loadgen_dataset_size=5000,loadgen_buffer_size=100 , get mAP
```
The mAP value and running time should be printed after a succesful run.
<details><pre>
...
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.353
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.541
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.371
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.182
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.378
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.505
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.310
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.494
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.538
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.339
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.571
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.706
mAP=35.292%

real    4m11.754s
</pre></details>


## Benchmarking RetinaNet_COCO model in the Performance mode

Two important changes for performance mode should be taken into account:
1. There is no way to measure mAP (LoadGen's constraint)
2. You need to "guess" the `loadgen_target_qps` parameter, from which the testing regime will be generated in order to measure the actual QPS.

So `TargetQPS` is the input, whereas `QPS` is the output of this benchmark:
```
axs byquery loadgen_output,detected_coco,framework=onnx,model_name=retinanet,loadgen_dataset_size=5000,loadgen_buffer_size=100,loadgen_mode=PerformanceOnly,loadgen_target_qps=38,verbosity=1 , dig summary.Samples_per_second

32.5764
```
