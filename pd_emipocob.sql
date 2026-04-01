drop procedure pd_emipocob;
create procedure "informix".pd_emipocob(old_no_poliza char(10),
                             old_no_unidad char(5),
                             old_cod_cobertura char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emicobde"
    delete from emicobde
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad
     and   cod_cobertura = old_cod_cobertura;

    --  Delete all children in "emicobre"
    delete from emicobre
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad
     and   cod_cobertura = old_cod_cobertura;
end procedure                                              
