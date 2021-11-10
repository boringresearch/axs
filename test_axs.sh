#!/bin/bash

source assert.sh

assert 'echo "Hello, world!"' 'Hello, world!'
assert_end testing_assert_itself

assert 'axs get xyz --xyz=123' 123
assert 'axs dig greek.2 --greek,=alpha,beta,gamma,delta' 'gamma'
assert 'axs substitute "Hello, #{x}#" --x=mate' 'Hello, mate'
assert_end on_the_fly_data_access

axs fresh_entry , plant greeting Hello address mate n 42 , save foo
assert 'axs bypath foo , get n' 42
assert 'axs bypath foo , substitute "#{greeting}#, #{address}#!"' 'Hello, mate!'
rm -rf foo
assert_end entry_creation_and_data_access

assert "axs mi: bypath missing , plant alpha 10 beta 20 , plant formula --:='^^:substitute:#{alpha}#-#{beta}#' , own_data" "{'alpha': 10, 'beta': 20, 'formula': '10-20'}"
assert "axs mi: bypath missing , plant alpha 10 beta 20 , plant formula --:='AS^IS:^^:substitute:#{alpha}#-#{beta}#' , own_data" "{'alpha': 10, 'beta': 20, 'formula': ['^^', 'substitute', '#{alpha}#-#{beta}#']}"
assert "axs mi: bypath missing , plant alpha 10 beta 20 , plant formula --:='AS^IS:^^:substitute:#{alpha}#-#{beta}#' , get formula --alpha=30" "30-20"
assert "axs mi: bypath missing , plant alpha 10 beta 20 , plant formula --:='AS^IS:^^:substitute:#{alpha}#-#{beta}#' , get formula --alpha=30 , get mi , own_data" "{'alpha': 10, 'beta': 20, 'formula': ['^^', 'substitute', '#{alpha}#-#{beta}#']}"
assert_end escaping_nested_calls_immediate_execution

axs fresh_entry , plant alpha 10 beta 20 gamma 30 multisub --:="AS^IS:^^:substitute:#{alpha}#, #{beta}# and #{gamma}#" , save grandma
axs fresh_entry , plant beta 200 gamma 300 _parent_entries --,:=AS^IS:^:bypath:grandma , save mum
assert 'axs bypath mum , substitute "#{alpha}# and #{beta}#"' '10 and 200'
assert 'axs bypath mum , get multisub --beta=2000' '10, 2000 and 300'
axs fresh_entry , plant gamma 31 delta 41 epsilon 51 zeta 60 multisub2 --,:="AS^IS:^^:substitute:#{gamma}#-#{delta}#,AS^IS:^^:substitute:#{epsilon}#-#{zeta}#" , save granddad
axs fresh_entry , plant delta 410 epsilon 510 _parent_entries --,:=AS^IS:^:bypath:granddad , save dad
axs fresh_entry , plant lambda 7000 mu 8000 _parent_entries --,:=AS^IS:^:bypath:dad,AS^IS:^:bypath:mum , save child
assert 'axs bypath child , substitute "#{alpha}#+#{beta}#, #{gamma}#-#{delta}#, #{epsilon}#*#{lambda}#"' '10+200, 31-410, 510*7000'
assert 'axs bypath dad , get multisub2 --delta=411 --zeta=611' "['31-411', '510-611']"
assert 'axs d: bypath dad , dig d.multisub2.1 --epsilon=3333' "3333-60"
assert 'axs d: bypath dad , dig d.multisub2.1 --epsilon=3333 , get d , dig d.multisub2.1 --epsilon=4444' "4444-60"
axs bypath child    , remove
axs bypath mum      , remove
axs bypath grandma  , remove
axs bypath dad      , remove
axs bypath granddad , remove
assert_end entry_creation_multiple_inheritance_and_removal

axs byquery git_repo,name=counting_collection
assert 'axs byname French , dig number_mapping.5' 'cinq'
axs byquery git_repo,name=counting_collection , pull
axs byname counting_collection , remove
axs byquery shell_tool,can_git --- , remove
assert_end git_cloning_collection_access_and_removal

axs work_collection , attached_entry examplepage_recipe , plant url http://example.com/ entry_name examplepage_downloaded file_name example.html _parent_entries --,:=AS^IS:^:byname:downloader , save
axs byname examplepage_recipe , call
assert 'axs byquery downloaded,file_name=example.html , file_path: get_path , byquery shell_tool,can_compute_md5 , run' '84238dfc8092e5d9c0dac8ef93371a07'
axs byquery shell_tool,can_compute_md5 --- , remove
axs byquery downloaded,file_name=example.html --- , remove
axs byname examplepage_recipe , remove
axs byquery shell_tool,can_download_url --- , remove
assert_end url_downloading_recipe_activation_and_removal

assert 'axs byname numpy_import_test , deps_versions --pillow_query+,=package_version=8.1.2' 'numpy==1.19.4, pillow==8.1.2'
assert 'axs byname numpy_import_test , multiply 1 2 3 4 5 6' '[17, 39]'
axs byquery --,=python_package,package_name=pillow --- , remove
axs byquery --:=python_package:package_name=numpy --- , remove
axs byquery --/=shell_tool/can_python --- , remove
assert_end dependency_installation_and_resolution_for_internal_code

# The following line is split into two to provide more insight into what is going on.
# Otherwise assert() blocks all the error output and the command looks "stuck" for quite a while.
export INFERENCE_OUTPUT=`axs byname torch_script_test , run --torchvision_query+=package_version=0.10.1 --output_file_path=`
assert "echo $INFERENCE_OUTPUT" '[65, 795, 230, 809, 520, 65, 334, 852, 674, 332, 109, 286, 370, 757, 595, 147, 327, 23, 478, 517]'
axs byname torch_script_test , run --num_of_images=32
assert 'axs byquery script_output , get accuracy' '0.71875'

axs byquery script_output --- , remove
axs byquery imagenet_aux,extracted --- , remove
axs byquery imagenet_aux,downloaded --- , remove

axs byquery extracted,archive_name=ILSVRC2012_img_val_500.tar --- , remove
axs byquery shell_tool,can_extract_tar --- , remove

axs byquery downloaded,file_name=ILSVRC2012_img_val_500.tar --- , remove
axs byquery shell_tool,can_compute_md5 --- , remove
axs byquery shell_tool,can_download_url --- , remove

axs byquery python_package,package_name=torchvision --- , remove
axs byquery shell_tool,can_python --- , remove
assert_end dependency_installation_and_resolution_for_external_python_script

echo "axs tests done"

