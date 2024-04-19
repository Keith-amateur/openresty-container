FROM debian:12 as builder
ARG OPENRESTY_VER=1.25.3.1
ARG PCRE_VER=8.45
ARG OPENSSL_VER=1.1.1w
ARG ZLIB_VER=1.2.13
WORKDIR /build
ADD openresty-"$OPENRESTY_VER".tar.gz openssl-"$OPENSSL_VER".tar.gz pcre-"$PCRE_VER".tar.gz zlib-"$ZLIB_VER".tar.gz /build
COPY openresty-config.sh /build
RUN apt update && apt -y install build-essential && \
	cd /build/pcre-${PCRE_VER} && ./configure --prefix=/opt/pcre-${PCRE_VER} --enable-jit --enable-utf8 --enable-unicode-properties --disable-static && make -j$(nproc) && make install && \
	cd /build/zlib-${ZLIB_VER} && ./configure --prefix=/opt/zlib-${ZLIB_VER} && make -j$(nproc) && make install && \
	cd /build/openssl-${OPENSSL_VER} && ./Configure --prefix=/opt/openssl-${OPENSSL_VER} threads linux-x86_64 && make -j$(nproc) && make install && \
	cd /build/openresty-${OPENRESTY_VER} && \
	chmod 755 /build/openresty-config.sh && mv /build/openresty-config.sh /build/openresty-${OPENRESTY_VER}/ && \
	/build/openresty-${OPENRESTY_VER}/openresty-config.sh && make -j$(nproc) && make install && \
	rm -rf /opt/pcre-${PCRE_VER}/include /opt/pcre-${PCRE_VER}/share /opt/pcre-${PCRE_VER}/bin /opt/pcre-${PCRE_VER}/lib/pkgconfig && \
	cd /opt/pcre-${PCRE_VER}/lib && find . ! -name "*libpcre.so*" -type f -exec rm -f {} \; && find . ! -name "*libpcre.so*" -type l -exec rm -f {} \; && \
	rm -rf /opt/openssl-${OPENSSL_VER}/include /opt/openssl-${OPENSSL_VER}/share /opt/openssl-${OPENSSL_VER}/bin /opt/openssl-${OPENSSL_VER}/ssl /opt/openssl-${OPENSSL_VER}/pkgconfig && \
	cd /opt/openssl-${OPENSSL_VER}/lib && find . -name "*.a" -type f -exec rm -f {} \; && \
	rm -rf /opt/zlib-${ZLIB_VER}/include /opt/zlib-${ZLIB_VER}/share /opt/zlib-${ZLIB_VER}/lib/pkgconfig /opt/zlib-${ZLIB_VER}/lib/libz.a

FROM busybox:glibc
ARG OPENRESTY_VER=1.25.3.1
WORKDIR /web-app
COPY --from=builder /opt /opt
COPY --from=builder /lib/x86_64-linux-gnu/libcrypt.so.1.1.0 /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/

ENV PATH=$PATH:/opt/openresty-${OPENRESTY_VER}/bin
RUN ln -s /lib/libcrypt.so.1.1.0 /lib/libcrypt.so.1 && \
		ln -s /opt/openresty-${OPENRESTY_VER}/nginx default && \
		ln -sf /dev/stdout /opt/openresty-${OPENRESTY_VER}/nginx/logs/access.log && \
		ln -sf /dev/stderr /opt/openresty-${OPENRESTY_VER}/nginx/logs/error.log && \
		addgroup nogroup
ENTRYPOINT ["openresty", "-g", "daemon off;", "-p"]
CMD ["default"]
