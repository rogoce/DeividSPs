--procedimiento para eliminar una requisición a solicitud o una transaccion de reclamos dentro de una requisición NO pagadas.
--Armando Moreno M.
--09/05/2024

drop procedure sp_che232;
create procedure sp_che232(a_no_requis char(10), a_usuario char(8), a_transaccion char(10) default "", a_opc smallint default 0)
RETURNING smallint,char(90);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

define _monto 		 dec(16,2);
define _cnt,_pagado  smallint;
DEFINE _a_nombre_de  varchar(100);
define _fecha        datetime year to fraction(5);

let _monto = 0.00;
let _fecha = current;

BEGIN
SET LOCK MODE TO WAIT;

select count(*)
  into _cnt
  from chqchmae
 where no_requis = a_no_requis;
 
select pagado,
	   a_nombre_de
  into _pagado,
	   _a_nombre_de
  from chqchmae
 where no_requis = a_no_requis;
 
--*******************************
-- OPC = 1 = VALIDACIONES********
--*******************************
if a_opc = 1 then
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
		return 1,"REQUISICION NO EXISTE, VERIFIQUE...";
	end if
	
	if _pagado = 0 then
	else
		return 1, "ESTA REQUISION YA ESTA PAGADA, VERIFIQUE...";
	end if

	select count(*)
	  into _cnt
	  from recordam
	 where no_requis = a_no_requis;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	--****Validando que la requis no este en una O/C
	if _cnt > 0 then
		return 1, "ESTA REQUISICION SE ENCUENTRA EN UNA ORDEN DE COMPRA, NO PUEDE SER AJUSTADA O ELIMINADA";
	end if
	return 0,'Validaciones Ok';
else
	if a_transaccion is not null And a_transaccion <> "" then
		select count(*)
		  into _cnt
		  from chqchrec
		 where no_requis = a_no_requis
		   and transaccion = a_transaccion;
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then
			return 1,"TRANSACCION NO EXISTE EN LA REQUISICION, VERIFIQUE...";
		end if
		select pagado
		  into _pagado
		  from rectrmae
		 where transaccion = a_transaccion;
		if _pagado = 0 then
		else
			return 1,"TRANSACCION YA HA SIDO PAGADA, VERIFIQUE...";
		end if
	end if
	--*******************************
	--PROCESO************************
	--*******************************
	--*Si solo tiene un transaccion, se debe eliminar la REQUISICION

	select count(*)
	  into _cnt
	  from chqchrec
	 where no_requis   = a_no_requis;

	if _cnt is null then
		let _cnt = 0;
	end if
	If _cnt = 1 then
		let a_transaccion = "";
	end if

	if a_transaccion = "" then						--Borra la requis y habilita las transacciones
		update rectrmae
		   set no_requis      = null,
			   generar_cheque = 0
		 where no_requis      = a_no_requis;

		delete from chqchpoa
		 where no_requis = a_no_requis;

		delete from chqchpol
		 where no_requis = a_no_requis;

		delete from chqchdes
		 where no_requis = a_no_requis;

		delete from chqchrec
		 where no_requis   = a_no_requis;

		delete from recunino
		 where no_requis = a_no_requis;

		delete from chqchcta
		 where no_requis = a_no_requis;

		delete from chqchmae
		 where no_requis = a_no_requis;
	else								--elimina una transaccion de la requis
		update rectrmae
		   set no_requis      = null,
			   generar_cheque = 0
		 where transaccion = a_transaccion;

		delete from chqchrec
		 where no_requis   = a_no_requis
		   and transaccion = a_transaccion;

		select sum(monto)
		  into _monto
		  from chqchrec
		 where no_requis = a_no_requis;
		 
		update chqchmae
		   set monto     = _monto
		 where no_requis = a_no_requis;
		 
	end if
	--Insertar Bitacora
	INSERT INTO chqbitsal(no_requis,a_nombre_de,transaccion,user_added,date_added)
	VALUES(a_no_requis,_a_nombre_de,a_transaccion,a_usuario,_fecha);
	return 0,'Proceso Completado';
end if	
END
end procedure