const { fstat } = require('fs');

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    swcMinify: true,
    webpack: (config) => {
        config.resolve.fallback = {
            fs: false,
            http: false,
            https: false,
            crypto: false,
            stream: false,
            querystring: false,
        };

        return config;
    },
};

module.exports = nextConfig;
