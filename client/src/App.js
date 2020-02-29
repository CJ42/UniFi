import React, { Component } from "react";
import UniFi from "./contracts/Unifi.json";
import Button from '@material-ui/core/Button';
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  img_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQzSq8VnVHZw7-8Cn7YXQKCQpDXinPEaEucFrySgMi4dk88qaFQ";
  
  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = UniFi.networks[networkId];
      const instance = new web3.eth.Contract(
        UniFi.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    // await contract.methods.set(5).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    // const response = await contract.methods.get().call();

    // Update state with the result.
    // this.setState({ storageValue: response });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <img src={this.img_url} />
        <div>
        <Button variant="contained" color="primary">
        Login
        </Button>
        <Button variant="contained" color="secondary">
          Register
        </Button>
        </div>
      </div>
    );
  }
}

export default App;
