-- Procedimiento que Realiza la anulacion automatica.

-- Creado    : 08/09/2017 - Autor: Amado Perez M.

drop procedure sp_rea42;

create procedure "informix".sp_rea42(
a_valor_ant       	char(10),
a_valor_nvo		  	char(10),
a_user			  	char(10)
) RETURNING   	  	INTEGER,char(100);

define _error 		   	  integer;
define _no_cheque	   	  integer;
define _transaccion	   	  char(10);
define _fecha_actual   	  date;
define v_periodo	   	  char(7);
define _renglon		   	  smallint;
define _resultado         integer;
define _debito            dec(16,2);
define _credito           dec(16,2);
define _mensaje			  char(100);
define _wf_aprobado       smallint;
define _wf_incidente,_cuantos      integer;
define _desc			  char(50);
define _actualizado       smallint;
define _pagado_nt  		  smallint;
define _cantidad          smallint;
define _mes               char(2);
define _ano               char(4);

--SET DEBUG FILE TO "sp_rea42.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,"";         
END EXCEPTION

SET LOCK MODE TO WAIT;

select count(*)
  into _cantidad
  from reatrx1
 where anular_remesa = a_valor_ant; 

If _cantidad > 0 Then
	return 1,"Ya existe una remesa que anula esta, verifique";
End If

let _fecha_actual = today;

IF MONTH(_fecha_actual) < 10 THEN
	LET v_periodo = YEAR(_fecha_actual) || '-0' || MONTH(_fecha_actual);
	LET _ano = YEAR(_fecha_actual);
	LET _mes = '0' || MONTH(_fecha_actual);
ELSE
	LET v_periodo = YEAR(_fecha_actual) || '-' || MONTH(_fecha_actual);
	LET _ano = YEAR(_fecha_actual);
	LET _mes = MONTH(_fecha_actual);
END IF

update reatrx1
   set user_anulo     = a_user,
	   fecha_anulo    = _fecha_actual,
	   anular_remesa  = a_valor_nvo
 where no_remesa      = a_valor_ant;

select * 
  from reatrx1
 where no_remesa = a_valor_ant
  into temp prueba;

update prueba 
   set no_remesa = a_valor_nvo
 where no_remesa = a_valor_ant;

insert into reatrx1
select * 
  from prueba
 where no_remesa = a_valor_nvo;

drop table prueba;

select debito,
       credito
  into _debito,
       _credito
  from reatrx1
 where no_remesa = a_valor_ant;

update reatrx1
   set fecha		     = _fecha_actual,
	   anular_remesa     = a_valor_ant,
	   monto             = monto * -1,
	   periodo           = v_periodo,
	   usuario           = a_user,
	   user_anulo        = a_user,
	   fecha_anulo       = _fecha_actual,
	   debito            = _credito,
	   credito           = _debito,
	   descrip           = "REVERSO DE REMESA " || a_valor_ant,
	   actualizado       = 0,
	   sac_asientos      = 0,
	   mes               = _mes,
	   ano               = _ano
 where no_remesa         = a_valor_nvo;

------------------
select * 
  from reatrx2
 where no_remesa = a_valor_ant
  into temp prueba;

update prueba 
   set no_remesa = a_valor_nvo
 where no_remesa = a_valor_ant;

insert into reatrx2
select * 
  from prueba
 where no_remesa = a_valor_nvo;

foreach 
	select renglon,
	       debito,
		   credito
	  into _renglon,
	       _debito,
		   _credito
     from reatrx2
    where no_remesa = a_valor_ant
	
	update reatrx2
	   set debito     = _credito,
           credito    = _debito	   
	 where no_remesa  = a_valor_nvo
	   and renglon    = _renglon;
end foreach

drop table prueba;
------------------
select * 
  from reatrx3
 where no_remesa = a_valor_ant
  into temp prueba;

update prueba 
   set no_remesa = a_valor_nvo
 where no_remesa = a_valor_ant;

insert into reatrx3
select * 
  from prueba
 where no_remesa = a_valor_nvo;

update reatrx3
   set monto            = monto * -1
 where no_remesa        = a_valor_nvo;

drop table prueba;

return 0,a_valor_nvo;
END
end procedure