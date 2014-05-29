# run all the scripts
date
echo "1.running launch_instance.pl......"
./launch_instance.pl $1
date
echo "2.sleeping for 3 mins......."
date
sleep 180
date
echo "3.running install_s3fs.pl....."
./install_s3fs.pl $1
date
echo "4.running s3_bucket.pl......"
./s3_bucket.pl $1
date
echo "5.running mount_s3fs.pl......"
./mount_s3fs.pl $1
date
echo "6.running s3fs_ops.pl......."
./s3fs_ops.pl $1
