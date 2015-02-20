// Playground - noun: a place where people can play

protocol InfoProvider {
    func getInfo() -> String
}


class A : InfoProvider {
    func getInfo() -> String {
        return "mmM"
    }
}


let a=A();

a.getInfo()





