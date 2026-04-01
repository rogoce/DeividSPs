-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure sp_rec95;

create procedure sp_rec95(a_transaccion char(10))
returning integer,
          varchar(100);

define _no_requis		char(10);
define _monto			dec(16,2);
define _mon  			dec(16,2);
define _pagado			smallint;
define _cantidad		integer;
define _no_cheque		integer;
define _anulado			smallint;
define _control_flujo   smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _mensaje         varchar(100);

--set debug file to "sp_rec95.trc";
--trace on;
--set isolation to dirty read;

SET LOCK MODE TO WAIT;

let _error = 0;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _anulado = 0;
let _mon     = 0;
let _cantidad = 0;

-- Verificando que no este en un ajuste por actualizar CASO: 36618 USER: ICASTILL 
call sp_rec314(a_transaccion) returning _error, _mensaje; 

if _error <> 0 then
	return _error, _mensaje; 
end if

-- Verificando que no tenga ya una transacción para anular
select count(*)
  into _cantidad
  from rectrmae
 where anular_nt = a_transaccion 
   and no_tranrec not in ('1537820','1664098','2838306','2577690',
'2472842',
'2337674',
'2621844',
'2621843',
'2605240',
'2579468',
'2605244',
'2549467'); 

If _cantidad > 0 Then
	return 1,"Ya existe una transaccion que anula esta, verifique";
End If

select max(no_requis)
  into _no_requis
  from chqchrec
 where transaccion = a_transaccion;

foreach
	select monto
	  into _mon
	  from chqchrec
	 where transaccion = a_transaccion
	exit foreach;
end foreach
if _mon = 0 then
	return 0,"";
end if

if _no_requis is null then	 --no tiene requisicion.
	return 0,"";
end if

select pagado,
	   no_cheque,
	   anulado,
	   cod_banco,
	   cod_chequera
  into _pagado,
	   _no_cheque,
	   _anulado,
	   _cod_banco,
	   _cod_chequera
  from chqchmae
 where no_requis = _no_requis;

let _control_flujo = 0;

select control_flujo
  into _control_flujo
  from chqchequ
 where cod_banco    = _cod_banco
   and cod_chequera	= _cod_chequera;

if _pagado = 0 then

	{select wf_aprobado,
	       wf_incidente,
		   transaccion
	  into _wf_aprobado,
	       _wf_incidente,
		   _transaccion
	  from rectrmae
	 where transaccion = a_transaccion;

	if _wf_aprobado = 1 and (_wf_incidente is not null or _wf_incidente <> "") then --debe ir a aprobacion
		 if _anular_nt = "" or _anular_nt is null then
			return 0,"";
		 end if
	end if}

	select count(*)
	  into _cantidad
	  from chqchrec	c, rectrmae t
	 where c.no_requis    = t.no_requis
	   and c.no_requis    = _no_requis
	   and t.cod_tipotran <> "013";	   --se incluye esto para que no tome en cuenta las N/T de declinacion Armando 17/02/2011

	select monto
	  into _monto
	  from chqchrec
	 where no_requis   = _no_requis
	   and transaccion = a_transaccion;

	if _cantidad > 1 then

		update rectrmae
		   set no_requis = null,
		       generar_cheque = 0
		 where no_requis   = _no_requis
		   and transaccion = a_transaccion;

		delete from chqchrec
		 where no_requis   = _no_requis
		   and transaccion = a_transaccion;

		update chqchmae
		   set monto     = monto - _monto
		 where no_requis = _no_requis;
		

	else
		-- Borrar todo en cascada (requisicion)

		update rectrmae
		   set no_requis      = null,
		       generar_cheque = 0
		 where no_requis      = _no_requis
		   and transaccion    = a_transaccion;

		delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

		delete from chqchdes
		 where no_requis = _no_requis;

		delete from chqchrec
		 where no_requis   = _no_requis;

		delete from recunino
		 where no_requis = _no_requis;

		delete from chqchcta
		 where no_requis = _no_requis;

		delete from chqchmae
		 where no_requis = _no_requis;

	end if

	if _control_flujo = 1 then
		{update chqchequ
		   set monto_disponible = monto_disponible - _monto
		 where cod_banco 	    = _cod_banco
		   and cod_chequera     = _cod_chequera;}
	end if

elif _pagado = 1 and _anulado = 1 then
	return 0,"";
elif _pagado = 1 then
	return 1, "No Puede anular esta Transaccion por que esta pagada en el cheque: " || _no_cheque;
end if
return 0,"";
end
end procedure
