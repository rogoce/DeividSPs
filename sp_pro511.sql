-- Procedimiento que verifica si la poliza lleva depreciacion Endoso Beneficio Ancon Plus.
-- Al retornar 0 se deprecia
-- v_poliza es la póliza anterior

-- CREADO: 09/05/2011 POR: Amado

drop procedure sp_pro511;

create procedure "informix".sp_pro511(
v_poliza 			char(10),
a_no_unidad 		char(5),
a_producto          char(5)
)
returning smallint;		--saber si lleva depreciacion

define _cod_ramo          char(3);
define _nueva_renov       char(1);
define _fecha_suscripcion date;
define _cant              smallint;
define _cant_cob          smallint;
define _uso_auto          char(1);
define _no_motor          char(30);
define _ano_auto          integer;
define _ano_sus           integer;
define _nuevo             smallint;
define _prima_anual       dec(16,2);

--SET DEBUG FILE TO "sp_pro511.trc"; 
--trace on;

set isolation to dirty read;

let _cant = 0;

select nueva_renov,
       cod_ramo,
	   fecha_suscripcion
  into _nueva_renov,
       _cod_ramo,
	   _fecha_suscripcion
  from emipomae
 where no_poliza = v_poliza;

let _ano_sus = year(_fecha_suscripcion);
let _ano_sus = _ano_sus + 1;

{select count(*)
  into _cant
  from emipouni
 where no_poliza = v_poliza
   and no_unidad = a_no_unidad
   and cod_producto = '00312';
}
select count(*)
  into _cant_cob
  from emipocob
 where no_poliza = v_poliza
   and no_unidad = a_no_unidad
   and cod_cobertura in ('00104','00122');

select uso_auto, no_motor
  into _uso_auto, _no_motor
  from emiauto
 where no_poliza = v_poliza
   and no_unidad = a_no_unidad;

select ano_auto, nuevo
  into _ano_auto, _nuevo
  from emivehic
 where no_motor = _no_motor;

if _nueva_renov = 'N' and _nuevo = 1 and a_producto in ('00312','02894','02699','10394','10395') then	 --> Poliza nueva 
   let _cant = _cant + 1;
end if

--02282 PETROAUTOS / SCOTIA BANK (SEDANES)
--02283 PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP)
--03810 AUTO COMPLETA – BANISI
--03811 PETROAUTOS / BANISI (SEDANES)
--03812 PETROAUTOS / BANISI (CAMIONETA Y PICK UP)
--07215 AUTO COMPLETA - BANISI / UNITY
--07755 AUTO COMPLETA - BANISI / UNITY
--07754 AUTO COMPLETA - CORP. DE CREDITO
--08278 AUTO COMPLETA - GENERAL REPRESENTATIVE

if _nueva_renov = 'N' and _nuevo = 1 and a_producto in ('02282','02283','03810','03811','03812','07215','07755','07754','08278') then	 --> Poliza nueva Banisi -- Amado 27-08-2024
   let _cant = _cant + 1;
end if

if _nuevo <> 1 then
--   return 0;
end if

if _cod_ramo not in ('002','023') then	 --> Solo Automovil y Flota
	let _cant = _cant + 1;
   -- return 0;
end if

if _fecha_suscripcion < '01/07/2010' then --> A partir de julio 2010
 --  return 0;
end if

--if a_producto in ('00312','02894', '02699') then  --> Producto Auto Completa
--	let _cant = _cant + 1;
 --  return 0;
--end if

if _cant_cob = 0 then --> Cobertura Reembolso Auto Sustituto
   --return 0;
else
	select prima_anual
	  into _prima_anual
	  from emipocob
	 where no_poliza = v_poliza
	   and no_unidad = a_no_unidad
	   and cod_cobertura in ('00104','00122');
	{if _prima_anual <> 45.00 then			--se puso en comentario 03/04/2016 Armando
   		return 0;
	end if}
end if

if _uso_auto <> 'P' then --> uso del auto particular
   --return 0;
end if

if _cant > 0 then
	return 1;
else
	return 0;
end if

end procedure;
