import type { NextPage } from 'next';
import { Box } from '@chakra-ui/react';
import { useAccount } from '../hooks';
import { useEffect } from 'react';

const Home: NextPage = () => {
    const { account } = useAccount();

    useEffect(() => {
        console.log(account);
    }, [account]);

    return <Box>Home</Box>;
};

export default Home;
