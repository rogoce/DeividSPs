create procedure "informix".pd_emifacon(old_no_poliza char(10),
                             old_no_endoso char(5),
                             old_no_unidad char(5),
                             old_cod_cober_reas char(3),
                             old_orden smallint)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "emifafac"
    delete from emifafac
    where  no_poliza = old_no_poliza
     and   no_endoso = old_no_endoso
     and   no_unidad = old_no_unidad
     and   cod_cober_reas = old_cod_cober_reas
     and   orden = old_orden;

end procedure                                                                                                                                   
