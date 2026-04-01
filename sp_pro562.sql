-- Buscando los pagos por tipo 1 -> Efectivo, 2-> Visa y Ach

-- CREADO: 		13/03/2017 POR: Amado
-- 

drop procedure sp_pro562;

create procedure sp_pro562(a_periodo1 char(7), a_periodo2 char(7))
returning	smallint;

define _tipo 		smallint;
define _monto 		dec(16,2);
define _no_remesa 	char(10);
define _renglon 	integer;
define _tipo_pago 	smallint;
define _cod_chequera char(3);

create temp table tmp_monto(
    tipo smallint,
	monto dec(16,2)) WITH NO LOG;

--- Actualizacion de Polizas

--set debug file to "sp_pro82e.trc";
--trace on;

begin

foreach	with hold
  select no_remesa,
         renglon
    into _no_remesa,
	     _renglon
	from cobredet
   where tipo_mov = 'P'
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
	elif _tipo_pago in (3,4) then	--Tarjetas debito / credito
		let _tipo = 3;
	elif _tipo_pago in (2) then 
	    let _tipo = 2;	--Cheques
	end if
	
	insert into tmp_monto (tipo, monto) values (_tipo, _monto);
  end foreach  
end foreach

foreach with hold
  select a.no_remesa,
         a.renglon,
		 a.monto,
		 b.cod_chequera
    into _no_remesa,
	     _renglon,
		 _monto,
		 _cod_chequera
	from cobredet a, cobremae b
   where a.no_remesa = b.no_remesa
     and a.tipo_mov = 'P'
     and a.periodo >= a_periodo1
     and a.periodo <= a_periodo2
	 and b.cod_chequera in ('029','030')
	 and b.actualizado = 1
	 
	if _cod_chequera = '030' then	--Ach
		let _tipo = 4;	--Ach
	else
		let _tipo = 5;	--Tarjeta credito
	end if
	insert into tmp_monto (tipo, monto) values (_tipo, _monto);

end foreach
end
return 0;
--DROP TABLE tmp_monto;
end procedure;