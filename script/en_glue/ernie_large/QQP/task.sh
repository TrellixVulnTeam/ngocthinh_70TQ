#!/bin/bash

R_DIR=`dirname $0`; MYDIR=`cd $R_DIR;pwd`
export FLAGS_eager_delete_tensor_gb=0.0
export FLAGS_sync_nccl_allreduce=1

if [[ -f ./model_conf ]];then
    source ./model_conf
else
    export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
fi

mkdir -p log/

for i in {1..5};do

  timestamp=`date "+%Y-%m-%d-%H-%M-%S"`

  python -u run_classifier.py                                                      \
       --for_cn False                                                              \
       --ernie_config_path script/en_glue/ernie_large/ernie_config.json            \
       --validation_steps 1000000000000                                            \
       --use_cuda true                                                             \
       --use_fast_executor ${e_executor:-"true"}                                   \
       --tokenizer ${TOKENIZER:-"FullTokenizer"}                                   \
       --use_fp16 ${USE_FP16:-"false"}                                             \
       --do_train true                                                             \
       --do_val true                                                               \
       --do_test true                                                              \
       --batch_size 32                                                             \
       --init_pretraining_params ${MODEL_PATH}/params                              \
       --verbose true                                                              \
       --train_set ${TASK_DATA_PATH}/QQP/train.tsv                                 \
       --dev_set   ${TASK_DATA_PATH}/QQP/dev.tsv                                   \
       --test_set  ${TASK_DATA_PATH}/QQP/test.tsv                                  \
       --vocab_path script/en_glue/ernie_large/vocab.txt                           \
       --checkpoints ./checkpoints                                                 \
       --save_steps 30000                                                          \
       --weight_decay  0.0                                                         \
       --warmup_proportion 0.1                                                     \
       --epoch 3                                                                   \
       --max_seq_len 128                                                           \
       --learning_rate 5e-5                                                        \
       --skip_steps 500                                                            \
       --num_iteration_per_drop_scope 1                                            \
       --num_labels 2                                                              \
       --metric 'acc_and_f1'                                                       \
       --test_save output/test_out.$i.$timestamp.tsv                               \
       --random_seed 1 2>&1 | tee  log/job.$i.$timestamp.log                       \

done
