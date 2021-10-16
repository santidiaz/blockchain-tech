// public, metodo que puede ser llamado desde el propio el contrato o cuenta externa al contrato
// external, solo puede ser llamado por cuentas externas al contrato. Variables no pueden ser extenral. Esto esta relacionado con como trabaja el EVM. La forma de ejecutar la funcion. Cuanod ejecuto una external, es capas de ejecutar la llamada desde el valor de los parametros.
// Si yo que que una funcion no la tengo que llamar desde dentro del contrato, tengo que 
// internal, puede ser llamado por cualquier cuenta que este dentro de la herencia o jerarquia de este contrato.
// private, solo se puede llamar desde este contrato.

// Events

// Modificadores metodos
// pure, indica que la funcion no le ni escribe en la blockchain. Toda interaccion con  estas funciones son gratis
// view, lee de la blockchain pero no escribe. No hay que pagar.
//
// payable

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; // Le indica al compilador cual es la version del compilador que vamos a usar

import "./ChildContract.sol";

// No tiene porque ser el mismo nombre del archivo.
contract ParentContract {
    // State variables
    string public myString;
    uint256 public var1;
    bool private _var2 = true;
    // SecondContract public myTestContract;
    
    // Mappings

    // Enums
    enum myEnum {
        op1,
        op2
    }

    // Structs
    struct myStruct {
        string name;
        uint256 edad;
    }

    uint256[] public myArray;
    mapping(uint256 => myStruct) public myMapping;
    mapping(uint256 => myStruct) public myMapping2;
    mapping(address => bool) public owners;

    // Address
    address public myAddress = address(0); // Address por defecto
    address payable public owner;
    address private _myAddress;
    
    // Events
    // event transferToken(address _from, address _to, uint256 _amount);
    event transferToken(address indexed _from, address indexed _to, uint256 _amount); // Indexed pq buscaria por from y to
    
    // emit transferToken(myAddress, addressTo, myAmount);
    
    // Modifiers [Utilizar solo para prevenir (buenas practicas)]
    // Patron ownable. Se definen funciones para Transferir la propiedad del contrato a otra ddres. Renunciar a la propiedad del contrato (Q: a quien le queda si el owner es unico?)
    modifier onlyOwner() {
        // msg.sender = Address de la cuenta que llamo a este contrato
        // Requiere que antes de la ejecucion, que quien pidio la ejecucion (el address) sea igual al address del <owner>.
        require(msg.sender == owner, "Not the owner.");
        _;
    }

    modifier onlyOwner2() {
        require(owners[msg.sender], "Not an owner.");
        _;
    }

    modifier balance(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    // Solo se deberian usar para prevenir ejecucion de funciones y no para encapsular codigo de ejecucion.
    // modifier emitMYEvent() {
    //    // require
    //    _; // Q: que significa esto?
    //    emit transferToken();
    // }

    // constructor
    constructor() {
        // Initialization
        var1 = 10;
        owner = payable(msg.sender);

        // msg.value
        // msg.gas
        // msg.data
        uint256 myDate = block.timestamp;
    }
    
    // Functions
    function firstFunction() public onlyOwner() {
        // return "Owner";
    }

    function getVersion() public pure virtual returns(string memory) {
        return "Version 1.0.0";
    }
    
    function myVariablePlus() public returns(uint) {
        var1 += 2;
        return var1;
    }
    
    function getMyBool() public view returns(bool) {
        return _var2;
    }

    /*
        State [balance, storage, nonce]
    */
    function getBalance() external view returns(uint256) {
        // Otro ejemplo: owner.balance;
        return address(this).balance;
    }

    // function withdraw(string memory _destinationAccount) external {
    function withdraw(uint256 _amount) external onlyOwner() balance(_amount) {
        // Solo donde necesito que sea un adress pagable lo casteo a payable
        // owner.transfer(address(this).balance);

        payable(owner).transfer(_amount);
        // .send no revierte la transferencia solo retorna false
        // bool result = payable(owner).send(_amount);
    }


    // Modifiers: Nos permite cambiar la forma en que una funcion de comporta. Solo lectura, solo escritura.
    // pure: solo voy a devolve la version. No voy a leer nada.
    // view: solo lectura de algun daot en la blockchain.

    // Patron Ownable - Se utiliza una variable publica <owner>
    
    // public, puede ser ejecutada desde fuera y desde dentro del contrato
    // external, solo puede ser llamada desde fuera del contrato.
    // internal, solo puede ser llamada/ver desde adentro del contrato.
    // private, solo pueden ser ejecutadas desde adentro del contrato, nada desde afuera
    
    // Private Functions

    function depositExample() external payable {
    }

    // ** van al final
    // Funcion especifica para recibir el dinero
    // Siempre external (no puedo recibir desde dentro del contrato y tiene que tener la palabra clave payable, le indica a la funcion que puede recibir dinero)
    // payable, le indica a la funcion que puede recibir dinero
    receive() external payable {
        // revert(); // rollback transaction
        // emit myEvent(); // Ejemplo logear algo.
    }

    // Se ejecuta cuando el data_load que me envian no coincide con ninguna funcion del contrato o no hay data_load
    fallback() external payable {}
}
