// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContractRegistry {
    struct ContractData {
        string cid;
        address uploader;
        uint256 timestamp;
    }

    ContractData[] private contracts;

    // mapping từ hash => true nếu đã lưu
    mapping(bytes32 => bool) private isStored;

    // mapping từ hash => uploader (để kiểm tra người xác minh)
    mapping(bytes32 => address) private hashToUploader;

    // mapping từ uploader => danh sách hash họ đã upload
    mapping(address => bytes32[]) private userUploads;

    event ContractUploaded(string cid, address indexed uploader, bytes32 indexed hash);

    /**
     * Lưu tài liệu lên blockchain qua CID
     */
    function storeCID(string memory _cid) public {
        bytes32 hash = keccak256(bytes(_cid));
        require(!isStored[hash], "Document already exists");

        contracts.push(ContractData(_cid, msg.sender, block.timestamp));
        isStored[hash] = true;
        hashToUploader[hash] = msg.sender;
        userUploads[msg.sender].push(hash);

        emit ContractUploaded(_cid, msg.sender, hash);
    }

    /**
     * Chỉ người đã upload tài liệu này mới xác minh được nó
     */
    function verifyDocument(bytes32 _hash) public view returns (bool) {
        return isStored[_hash] && hashToUploader[_hash] == msg.sender;
    }

    /**
     * Lấy thông tin tài liệu theo chỉ số
     */
    function getContract(uint index) public view returns (ContractData memory) {
        require(index < contracts.length, "Index out of range");
        return contracts[index];
    }

    /**
     * Tổng số tài liệu
     */
    function getTotalContracts() public view returns (uint) {
        return contracts.length;
    }

    /**
     * Lấy danh sách hash mà một uploader đã lưu
     */
    function getUploadsByUser(address user) public view returns (bytes32[] memory) {
        return userUploads[user];
    }
}
