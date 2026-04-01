-- Buscando los pagos por tipo 1 -> Efectivo, 2-> Visa y Ach

-- CREADO: 		13/03/2017 POR: Amado
-- 

drop procedure sp_pro562_salas;
create procedure sp_pro562_salas(a_periodo1 char(7), a_periodo2 char(7))
returning	char(3) as sucursal,
varchar(20) as nombre,
char(7) as periodo,
dec(16,2) as monto;	
--returning	smallint;
define _tipo 		smallint;
define _monto 		dec(16,2);
define _no_remesa 	char(10);
define _renglon 	integer;
define _tipo_pago 	smallint;
define _cod_sucursal char(3);
define _periodo      char(7);
define _nombre_sucursal varchar(20);
drop table if exists tmp_monto;	
create temp table tmp_monto(
    tipo         smallint,
	cod_sucursal char(3),
	periodo      char(7),
	monto        dec(16,2)) WITH NO LOG;

--- Actualizacion de Polizas

-- Mes, Sucursal y Monto en efectivo cobrado.

--set debug file to "sp_pro82e.trc";
--trace on;

let _nombre_sucursal = '';

begin

foreach	with hold
  select no_remesa,
         renglon,
		 periodo,
		 cod_sucursal
    into _no_remesa,
	     _renglon,
		 _periodo,
		 _cod_sucursal
	from cobredet
   where tipo_mov in ('P','N')
     and actualizado = 1
     and periodo >= a_periodo1
     and periodo <= a_periodo2
	 
  foreach with hold
	select importe,
	       tipo_pago
	  into _monto,
	       _tipo_pago
	  from cobrepag
	 where no_remesa = _no_remesa
	   and renglon = _renglon
	   
	if _tipo_pago in (1) then
		let _tipo = 1;	--Efectivo
	else
		continue foreach;
	end if
	
	insert into tmp_monto (tipo, monto,cod_sucursal,periodo) values (_tipo, _monto,_cod_sucursal,_periodo);
  end foreach  
  
end foreach

foreach
 select cod_sucursal, periodo, sum(monto)
  into _cod_sucursal,_periodo,_monto
 from tmp_monto
 where tipo = '1'
 group by cod_sucursal, periodo
 order by cod_sucursal, periodo


	 select descripcion
	   into _nombre_sucursal
	   from insagen
	  where codigo_agencia 		= _cod_sucursal
		and codigo_compania 	= '001';
			
	return _cod_sucursal,
			   _nombre_sucursal,
			   _periodo,
			   _monto	
			   with resume;			
			
			
end foreach

end
--return 0;
--DROP TABLE tmp_monto;
end procedure;