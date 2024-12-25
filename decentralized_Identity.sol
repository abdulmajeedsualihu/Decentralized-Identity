// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract DecentralizedIdentity{
    struct Identity{
        string name;
        string email; 
        string verificationDocument;
        bool isVerified;
        bool isRevoked;
        address owner;
    }

    //state variables
    mapping (address => Identity) public identities;
    mapping (address => bool) public authorizedVerifiers;

    address public manager;

    // Events
    event IdentityRegistered(address indexed user, string name, string email);
    event IdentityVerified(address indexed user, address indexed verifier);
    event IdentityRevoked(address indexed user, address indexed revoker);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    // Constructor
    constructor() {
        manager = msg.sender;
    }

    // Modifiers
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can perform this action"
        );
        _;
    }

    modifier onlyOwner(address user) {
        require(
            identities[user].owner == msg.sender,
            "Only the identity owner can perform this action"
        );
        _;
    }

    modifier onlyVerifier() {
        require(
            authorizedVerifiers[msg.sender],
            "Only authorized verifiers can perform this action"
        );
        _;
    }

    // Functions

    // Register an identity (_name Name, _email Email_verificationDocument Verification).

    function registerIdentity(
        string calldata _name,
        string calldata _email,
        string calldata _verificationDocument
    ) external {
        require(
            identities[msg.sender].owner == address(0),
            "Identity already registered"
        );

        identities[msg.sender] = Identity({
            name: _name,
            email: _email,
            verificationDocument: _verificationDocument,
            isVerified: false,
            isRevoked: false,
            owner: msg.sender
        });

        emit IdentityRegistered(msg.sender, _name, _email);
    }

    //  Verify an identity.
    // user Address of the identity owner to verify.

    function verifyIdentity(address user) external onlyVerifier {
        require(
            identities[user].owner != address(0),
            "Identity not registered"
        );
        require(!identities[user].isVerified, "Identity already verified");
        require(!identities[user].isRevoked, "Identity is revoked");

        identities[user].isVerified = true;

        emit IdentityVerified(user, msg.sender);
    }

    //  Revoke an identity.
    // param user Address of the identity owner to revoke.

    function revokeIdentity(address user) external onlyVerifier {
        require(
            identities[user].owner != address(0),
            "Identity not registered"
        );
        require(!identities[user].isRevoked, "Identity already revoked");

        identities[user].isRevoked = true;
        identities[user].isVerified = false;

        emit IdentityRevoked(user, msg.sender);
    }

    function getIdentity(address user)
        external
        view
        returns (
            string memory name,
            string memory email,
            string memory verificationDocument,
            bool isVerified,
            bool isRevoked,
            address owner
        )
    {
        Identity storage id = identities[user];
        return (
            id.name,
            id.email,
            id.verificationDocument,
            id.isVerified,
            id.isRevoked,
            id.owner
        );
    }

    // Add a new verifier.
    // verifier Address to authorize as a verifier.

    function addVerifier(address verifier) external onlyManager {
        require(!authorizedVerifiers[verifier], "Verifier already authorized");
        authorizedVerifiers[verifier] = true;

        emit VerifierAdded(verifier);
    }

    // notice Remove an existing verifier.
    // param verifier Address to remove from verifiers.

    function removeVerifier(address verifier) external onlyManager {
        require(authorizedVerifiers[verifier], "Verifier not authorized");
        authorizedVerifiers[verifier] = false;

        emit VerifierRemoved(verifier);
    }
}