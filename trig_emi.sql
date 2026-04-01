	-- ============================================================
--   Database name:  MODEL_5
--   DBMS name:      INFORMIX SQL 7.1
--   Created on:     06/11/00  04:17 p.m.
--   MODIFICADO : 23/11/2000 - EDGAR CANO
-- ============================================================

drop procedure pd_emidepen;

--  Delete procedure "pd_emidepen" for table "emidepen"
create procedure pd_emidepen(old_no_poliza char(10),
                             old_no_unidad char(5),
                             old_cod_cliente char(10))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emiprede"
    delete from emiprede
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad
     and   cod_cliente = old_cod_cliente;

end procedure;

drop trigger td_emidepen;

--  Delete trigger "td_emidepen" for table "emidepen"
create trigger td_emidepen delete on emidepen
referencing old as old_del
   for each row (execute procedure pd_emidepen(old_del.no_poliza,
                                               old_del.no_unidad,
                                               old_del.cod_cliente));

drop procedure pd_emifacon;

--  Delete procedure "pd_emifacon" for table "emifacon"
create procedure pd_emifacon(old_no_poliza char(10),
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

end procedure;

drop trigger td_emifacon;

--  Delete trigger "td_emifacon" for table "emifacon"
create trigger td_emifacon delete on emifacon
referencing old as old_del
   for each row (execute procedure pd_emifacon(old_del.no_poliza,
                                               old_del.no_endoso,
                                               old_del.no_unidad,
                                               old_del.cod_cober_reas,
                                               old_del.orden));

drop procedure pd_emifian;

--  Delete procedure "pd_emifian" for table "emifian1"
create procedure pd_emifian(old_no_poliza char(10),
                            old_no_unidad char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emifigar"
    delete from emifigar
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

end procedure;

drop trigger td_emifian;

--  Delete trigger "td_emifian" for table "emifian1"
create trigger td_emifian delete on emifian1
referencing old as old_del
   for each row (execute procedure pd_emifian(old_del.no_poliza,
                                              old_del.no_unidad));

drop procedure pd_emifigar;

--  Delete procedure "pd_emifigar" for table "emifigar"
create procedure pd_emifigar(old_no_poliza char(10),
                             old_no_unidad char(5),
                             old_cod_tipogar char(3))
    define  errnn    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "emiavan"
    delete from emiavan
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad
     and   cod_tipogar = old_cod_tipogar;

end procedure;

drop trigger td_emifigar;

--  Delete trigger "td_emifigar" for table "emifigar"
create trigger td_emifigar delete on emifigar
referencing old as old_del
   for each row (execute procedure pd_emifigar(old_del.no_poliza,
                                               old_del.no_unidad,
                                               old_del.cod_tipogar));

drop procedure pd_emigloco;

--  Delete procedure "pd_emigloco" for table "emigloco"
create procedure pd_emigloco(old_no_poliza char(10),
                             old_no_endoso char(5),
                             old_orden smallint)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emiglofa"
    delete from emiglofa
    where  no_poliza = old_no_poliza
     and   no_endoso = old_no_endoso
     and   orden = old_orden;

end procedure;

drop trigger td_emigloco;

--  Delete trigger "td_emigloco" for table "emigloco"
create trigger td_emigloco delete on emigloco
referencing old as old_del
   for each row (execute procedure pd_emigloco(old_del.no_poliza,
                                               old_del.no_endoso,
                                               old_del.orden));

drop procedure pd_emihcmm;

--  Delete procedure "pd_emihcmm" for table "emihcmm"
create procedure pd_emihcmm(old_no_poliza char(10),
                            old_no_cambio char(3))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

 
    --  Delete all children in "emihcmdd
    delete from emihcmd
    where  no_poliza = old_no_poliza
     and   no_cambio = old_no_cambio;

end procedure;

drop trigger td_emihcmm;

--  Delete trigger "td_emihcmm" for table "emihcmm"
create trigger td_emihcmm delete on emihcmm
referencing old as old_del
   for each row (execute procedure pd_emihcmm(old_del.no_poliza,
                                              old_del.no_cambio));
drop procedure pd_emipocob;

--  Delete procedure "pd_emipocob" for table "emipocob"
create procedure pd_emipocob(old_no_poliza char(10),
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

end procedure;

drop trigger td_emipocob;

--  Delete trigger "td_emipocob" for table "emipooob"
create trigger td_emipocob delete on emipocob
referencing old as old_del
   for each row (execute procedure pd_emipocob(old_del.no_poliza,
                                               old_del.no_unidad,
                                               old_del.cod_cobertura));

drop procedure pd_emireagm;

--  Delete procedure "pd_emigloco" for table "emireagm"
create procedure pd_emireagm(old_no_poliza char(10),
                             old_no_cambio char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emiglofa"
    delete from emireagc
    where  no_poliza = old_no_poliza
     and   no_cambio = old_no_cambio;

end procedure;

drop trigger td_emireagm;

--  Delete trigger "td_emigloco" for table "emireagm"
create trigger td_emireagm delete on emireagm
referencing old as old_del
   for each row (execute procedure pd_emireagm(old_del.no_poliza,
                                               old_del.no_cambio));

drop procedure pd_emipomae;

--  Delete procedure "pd_emipomae" for table "emipomae"
create procedure pd_emipomae(old_no_poliza char(10))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emipouni"
    delete from emipouni
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipoagt"
    delete from emipoagt
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emidirco"
    delete from emidirco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "endasien"
    delete from endasien
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emiciara"
    delete from emiciara
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoama"
    delete from emicoama
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoami"
    delete from emicoami
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emihcmm"
    delete from emihcmm
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolde"
    delete from emipolde
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emiporec"
    delete from emiporec
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolim"
    delete from emipolim
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emigloco"
    delete from emigloco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emireagm"
    delete from emireagm
    where  no_poliza = old_no_poliza;

end procedure;

drop trigger td_emipomae;

--  Delete trigger "td_emipomae" for table "eeipomae"
create trigger td_emipomae delete on emipomae
referencing old as old_del
   for each row (execute procedure pd_emipomae(old_del.no_poliza));

drop procedure pd_emipouni;

--  Delete procedure "pd_emipouni" for table "emipouni"
create procedure pd_emipouni(old_no_poliza char(10),
                             old_no_unidad char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emifacon"
    delete from emifacon
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

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

end procedure;

drop trigger td_emipouni;

--   Delete trigger "td_emipouni" for table "emipouni"
create trigger td_emipouni delete on emipouni
referencing old as old_del
   for each row (execute procedure pd_emipouni(old_del.no_poliza,
                                               old_del.no_unidad));
