// Source entry point for the native desktop application.
import ".flexscript/scripts/lib/build.flex";

fn collie_exec(binary,argc,argv){
    let args=h_take((argc+1)*8);store64(args,binary);let i=1;
    while i<argc{store64(args+i*8,load64(argv+i*8));i=i+1;}
    store64(args+argc*8,0);syscall(59,binary,args,h_env,0,0,0);
    h_die(h_cat("Cannot launch ",binary));return 1;
}
fn main(argc,argv){
    h_environment(argc,argv);
    let entry=load64(argv);let header=h_take(4);let fd=syscall(2,entry,0,0,0,0,0);
    h_assert(fd>=0,"Cannot open Collie entry point");let n=syscall(0,fd,header,4,0,0,0);h_close(fd);
    if n!=4 || load8(header)!=127 || load8(header+1)!=69 || load8(header+2)!=76 || load8(header+3)!=70{
        let compiler=h_getenv("COLLIE_COMPILER");if !h_len(compiler){compiler=h_real("/proc/self/exe");}
        compiler=h_real(h_executable(compiler));let source=h_real(entry);let root=h_dir(source);
        let build=h_join(root,"build");h_mkdir(build);
        let launcher=h_join(build,"collie-source-launcher");let temporary=h_cat(launcher,h_cat(".new-",h_int(syscall(39,0,0,0,0,0,0))));
        h_compile(compiler,source,temporary);
        h_assert(syscall(82,temporary,launcher,0,0,0,0)==0,"Cannot install Collie launcher");
        h_setenv("COLLIE_COMPILER",compiler);return collie_exec(launcher,argc,argv);
    }
    let caller=h_real(".");let root=h_dir(h_dir(h_real("/proc/self/exe")));
    h_timeout=180000;
    h_assert(syscall(80,root,0,0,0,0,0)==0,"Cannot enter Collie source directory");
    h_assert(h_exists(".flexscript/compiler/main.flex"),"Configure the SDK with ./configure first");
    let seed=h_getenv("COLLIE_COMPILER");if !h_len(seed){seed=h_executable("flexscript");}
    h_print(2,"Building Collie desktop...\n");
    let compiler=h_join(root,"build/compiler");let temporary=h_cat(compiler,h_cat(".new-",h_int(syscall(39,0,0,0,0,0,0))));
    h_compile(seed,".flexscript/compiler/main.flex",temporary);
    h_assert(syscall(82,temporary,compiler,0,0,0,0)==0,"Cannot install SDK compiler");
    let builder=h_join(root,"build/build-desktop");h_compile(compiler,"desktop/build.flex",builder);
    h_ok(h_args(builder,"--compiler",compiler,0,0,0));
    h_assert(syscall(80,caller,0,0,0,0,0)==0,"Cannot restore launch directory");
    return collie_exec(h_join(root,"build/collie-desktop/collie"),argc,argv);
}
