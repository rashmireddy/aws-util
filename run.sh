# run all the scripts
./launch_instances.pl $1
./s3fs_install.pl $1
./s3_bucket.pl $1
./mount_s3fs.pl $1
./s3fs_ops.pl $1