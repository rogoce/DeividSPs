-- Procedimiento que Realiza la anulacion automatica de N/T.

-- Creado    : 24/08/2006 - Autor: Armando Moreno M.

--drop procedure sp_rec127a;

create procedure "informix".sp_rec127a(
a_compania   		CHAR(3), 
a_sucursal   		CHAR(3), 
a_valor_ant       	char(10),
a_valor_nvo		  	char(10)
) RETURNING   	  	INTEGER,char(100);

define _error 		   	  integer;
define _no_cheque	   	  integer;
define _transaccion	   	  char(10);
define _fecha_actual   	  date;
define v_periodo	   	  char(7);
define _origen_cheque  	  char(1);
define _renglon		   	  smallint;
define _firma_electronica smallint;
define _cod_banco	   	  char(3);
define _cod_chequera   	  char(3);
define _tran_nvo		  char(10);
define _cod_cober		  char(5);
define ld_hoy			  date;
define _valor_parametro   integer;
define _monto_cober		  dec(16,2);
define _resultado         integer;
define _mensaje			  char(100);
define _wf_aprobado       smallint;
define _wf_incidente,_cuantos      integer;
define _desc			  char(50);
define _actualizado       smallint;
define _pagado_nt  		  smallint;

--SET DEBUG FILE TO "sp_rec127.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,"";         
END EXCEPTION

SET LOCK MODE TO WAIT;


select * 
  from rectrmae
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrmae
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;

-- Reaseguro de los Reclamos para los Asientos

{if _actualizado = 1 then

	call sp_rea008(3, a_valor_nvo) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if }

------------------
select * 
  from rectrcon
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrcon
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------
select * 
  from rectrcob
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrcob
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;


select * 
  from rectrde2
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;


insert into rectrde2
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------
select * 
  from rectrrea
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrrea
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------
select * 
  from rectrref
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrref
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------

return 0,_tran_nvo;
END
end procedure