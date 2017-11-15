import ceylon.collection {
    MutableSet,
    HashSet
}
import ceylon.language.meta {
    modules
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    ValueDeclaration,
    ClassDeclaration,
    Module
}

alias PossibleDeclaraitons => FunctionDeclaration|ValueDeclaration|ClassDeclaration;

"annotation to mark functions that require
 environment variables for their proper work"
shared final annotation
class RequireEnvAnnotation(shared String* envs) satisfies
        OptionalAnnotation<RequireEnvAnnotation,
        FunctionDeclaration|ValueDeclaration|ClassDeclaration> {}

"annotation to mark functions that require
 environment variables for their proper work"
shared annotation RequireEnvAnnotation requireEnv( String* envs)
        => RequireEnvAnnotation(*envs);

"Scan given modules for environment requirements.
 By default scan all runtime modules.
 Throws exception when requirement violated"
see(`class RequireEnvAnnotation`)
throws(`class AssertionError`)
shared void scanEnvRequirements(Module[] mods = modules.list) {
    MutableSet<String> vars = HashSet<String>();
    for (mod in mods) {
        for (pack in mod.members) {
            
            value members = pack
                .annotatedMembers<PossibleDeclaraitons, RequireEnvAnnotation>();
            
            if(nonempty members) {
                {String*} requirements = members
                    .flatMap((PossibleDeclaraitons fd)
                        => fd.annotations<RequireEnvAnnotation>()
                             .flatMap(RequireEnvAnnotation.envs));
                
                vars.addAll(requirements);
            }
        }
    }
    if(nonempty missedVars = [for (key in vars) if(!exists val = env[key]) key ]) {
        throw AssertionError("[``", ".join(missedVars)``] - variable(s) should be specified in environment");
    }
}
