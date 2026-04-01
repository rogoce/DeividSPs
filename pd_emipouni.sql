drop procedure pd_emipouni;

--  Delete procedure "pd_emipouni" for table "emipouni"
create procedure pd_emipouni(old_no_poliza char(10),
                             old_no_unidad char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emifacon"
   { delete from emifacon
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;}

    --  Delete all children in "emidepen"
    delete from emidepen
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

    --  Delete all children in "emipreas"
    delete from emipreas
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children in "emibenef"
    delete from emibenef
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children in "emipocob"
    delete from emipocob
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all cccldren in "emifian1"
   delete from emifian1
    where  no_poliza = old_no_poliza
    and   no_unidad = old_no_unidad;
 
    --  Delett all children in "emiauto"
    delete from emiauto
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children ii "emitrans"
    delete from emitrand
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

    --  Delete all children ii "emitrans"
    delete from emitrans
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children in "emicupol"
    delete from emicupol
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children in "emipoacr"
    delete from emipoacr
    where  no_poliza = old_no_poliza
      and  no_unidad = old_no_unidad;
 
    --  Delete all children in "emiunide"
    delete from emiunide
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
 
    --  Delete all children in "emiunire"
    delete from emiunire
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

    --  Delete all children in "emipode2"
    delete from emipode2
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

    --  Delete all children in "emirepod"
    delete from emirepod
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;
end procedure;