-- Simulacion de cambio de contrato de reaseguro
-- Crear registros Nuevos a partir de los anteriores

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 07/08/2012 - Autor: Armando Moreno

--execute procedure sp_sim001('00616','00613',2)


--DROP procedure sp_sim007a;

CREATE procedure "informix".sp_sim007a(
a_cod_cont_nvo CHAR(05),
a_cod_cont_ant CHAR(05)
) RETURNING    integer;


define _no_poliza char(10);
define _no_endoso char(5);
define _no_remesa char(10);
define _renglon   integer;
define _cnt,_cnt_acum integer;
define _no_tranrec char(10);
define _no_factura char(10);


set isolation to dirty read;


let _cnt = 0;
let _cnt_acum = 0;

select count(*)
  into _cnt
  from emifafac
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from emifacon
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from emireaco
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from emigloco
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from cobreaco
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from cobreafa
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from rectrrea
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

select count(*)
  into _cnt
  from rectrref
 where cod_contrato = a_cod_cont_ant;

let _cnt_acum = _cnt_acum + _cnt;

return _cnt_acum;
   
END PROCEDURE;
