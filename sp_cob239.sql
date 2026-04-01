-- Detalle programa cierre de caja

-- Creado    : 08/02/2010 - Autor: Armando Moreno
-- Modificado: 08/02/2010 - Autor: Armando Moreno


drop procedure sp_cob239;

create procedure "informix".sp_cob239(
a_fecha 		date, 
a_cod_chequera 	char(3),
a_no_caja	   	char(10) default "00000"
) returning smallint,
            char(3),
		    date,
		    integer,
		    char(100),
		    char(100),
		    dec(16,2),
		    char(10),
		    smallint,
		    smallint,
		    char(10);

define _renglon			  smallint;
define _cod_banco		  char(3);
define _fecha			  date;
define _no_cheque		  integer;
define _girado_por		  char(100);
define _a_favor_de		  char(100);
define _importe			  dec(16,2);
define _no_remesa		  char(10);
define _tipo_remesa		  char(1);
define _tipo_remesa2	  char(1);
define _tipo_pago		  smallint;
define _tipo_tarjeta	  smallint;
define _no_recibo		  char(10);

define _cantidad	      smallint;
define _monto_chequeo	  dec(16,2);

SET ISOLATION TO DIRTY READ;

let _no_recibo = "";

if a_no_caja <> "00000" then

	select tipo_remesa
	  into _tipo_remesa
	  from cobcieca
	 where no_caja = a_no_caja;

	let _tipo_remesa2 = _tipo_remesa;

else

	let _tipo_remesa  = "A";
	let _tipo_remesa2 = "M";

end if

--set debug file to "sp_cob239.trc";
--trace on;

FOREACH
	Select no_remesa,
	       monto_chequeo
	  Into _no_remesa,
		   _monto_chequeo
	  From cobremae
	 Where fecha        = a_fecha
	   and cod_chequera = a_cod_chequera
	   and actualizado  = 1
	   and (tipo_remesa  = _tipo_remesa or
	        tipo_remesa  = _tipo_remesa2)

	foreach
		select no_recibo
		  into _no_recibo
		  from cobredet
		 where no_remesa = _no_remesa
		   and actualizado = 1

		exit foreach;
	end foreach

	select count(*)
	  into _cantidad
	  from cobrepag
	 where no_remesa = _no_remesa;

	if _cantidad = 0 then

		insert into cobrepag(no_remesa, renglon, tipo_pago, tipo_tarjeta, cod_banco, fecha, no_cheque, girado_por, a_favor_de, importe)
		values (_no_remesa, 1, 1, null, null, null, null, null, null, _monto_chequeo);

	end if

	foreach

		  SELECT renglon,   
		         cod_banco,   
		         fecha,   
		         no_cheque,   
		         girado_por,   
		         a_favor_de,   
		         importe,   
		         no_remesa,   
		         tipo_pago,   
		         tipo_tarjeta
			INTO _renglon,
			     _cod_banco,
				 _fecha,
				 _no_cheque,
				 _girado_por,
				 _a_favor_de,
				 _importe,
				 _no_remesa,
				 _tipo_pago,
				 _tipo_tarjeta
		    FROM cobrepag   
		   WHERE no_remesa = _no_remesa

		Return _renglon,
		       _cod_banco,
		 	   _fecha,
		 	   _no_cheque,
		 	   _girado_por,
		 	   _a_favor_de,
			   _importe,
			   _no_remesa,
			   _tipo_pago,
			   _tipo_tarjeta,
			   _no_recibo
		 	   WITH RESUME;

	End Foreach

End Foreach

END PROCEDURE
