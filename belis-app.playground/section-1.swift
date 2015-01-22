// Playground - noun: a place where people can play

protocol EmptyInit {
    init();
}

class FirstBase {

}

class A : FirstBase, EmptyInit{
    required init(){
        
    }
}



class SecondBase : EmptyInit {
    required init(){
        
    }
}



A();


class B : SecondBase, EmptyInit {
    required init() {
        
    }
}

B();



func creation<T: EmptyInit>(x a:T.Type) -> T{
    var object = T()
    return object;
}


var b = creation(x: B.self);

//var a = creation(x: A.self);







let t=true

println("\(t)")




