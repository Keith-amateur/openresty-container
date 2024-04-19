#! /bin/bash
SRC_NAME=`basename $(pwd)`
LIBS=("/opt/pcre-8.45" "/opt/openssl-1.1.1w" "/opt/zlib-1.2.13")

echo "Configuring $SRC_NAME"
echo "Requires following LIBS"
for lib in ${LIBS[@]}; do
	echo -e -n "\t"`basename $lib`
	if [ -d $lib ]; then
		echo -e "\t\t  Found --$lib"
	else
		LIBS_PREPARED=no
		echo -e "\t\t  Not Found"
	fi
done

[ -n "$LIBS_PREPARED" ] && exit 1

# read -p "Proceed? [Y/n]:" RES
# case $RES in
# 	Y|y) echo "Starting..." ;;
# 	*) exit 1;;
# esac

[ -x ./configure ] || {
	echo "./configure not exist";
	exit 1;
}

./configure --prefix=/opt/"$SRC_NAME" \
	--with-cc-opt="-I${LIBS[0]}/include -I${LIBS[1]}/include -I${LIBS[2]}/include" \
	--with-ld-opt="-L${LIBS[0]}/lib -L${LIBS[1]}/lib -L${LIBS[2]}/lib -Wl,-rpath,${LIBS[0]}/lib:${LIBS[1]}/lib:${LIBS[2]}/lib" \
	--with-pcre-jit \
	--with-stream --with-stream_ssl_module --with-stream_ssl_preread_module \
	--with-http_v2_module \
	--without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module \
	--with-http_stub_status_module --with-http_realip_module --with-http_addition_module --with-http_auth_request_module --with-http_secure_link_module --with-http_random_index_module --with-http_gzip_static_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module \
	--with-threads \
	--with-compat
