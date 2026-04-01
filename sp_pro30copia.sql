-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

--drop procedure sp_pro30copia;
create procedure sp_pro30copia(a_no_poliza char(10))
returning smallint,
          char(50);

define _fecha_nac		date;
define _edad			smallint;
define _anos			smallint;
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _producto_nuevo	char(5);
define _prima_total		dec(16,2);
define _prima_plan		dec(16,2);
define _prima_vida		dec(16,2);
define _cantidad		smallint;

define _porc_descuento  dec(5,2);
define _porc_recargo    dec(5,2);
define _porc_impuesto   dec(5,2);
define _porc_coas       dec(7,4);

define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipoprod	char(3);

define _cod_perpago		char(3);
define _meses			smallint;

define _no_unidad		char(5);
define _prima			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _cambiar_tarifas	smallint;
define _no_documento	char(20);

define _error			smallint;
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);

DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo CHAR(7);
define _tar_salud       smallint;
define _cod_depend      CHAR(10);
define _prima_plan_dep	dec(16,2);
define _prima_vida_dep	dec(16,2);
define _tarifa_dep	    dec(16,2);
define _tarifa_dep_tot 	dec(16,2);
DEFINE _fecha_aniversario 	DATE;
DEFINE _cod_grupo       CHAR(3);
DEFINE _fecha_a         date;
define _anno,_ano_salno integer;
define _cod_cober       char(5);
define _desc_limite1    varchar(50,0);
define _desc_limite2	varchar(50,0);
define _orden_n         smallint;
define _ded_n           varchar(50);
define _ded_nn          dec(16,2);
define v_fecha_r        date;
define _prima_nn        dec(16,2);
define _cnt             integer;
define _cod_parentesco  char(3);
define _tipo_pariente,_tipo_par_prod   smallint;

--set debug file to "sp_pro30c.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Cambiar Tarifas...";
end exception

let _fecha_a  = current;
let _anno     = year(_fecha_a);
LET v_fecha_r = current;
let _cnt      = 0;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;
 
select ano
  into _ano_salno
  from prdsalno
 where no_documento = _no_documento;

select count(*)
  into _cantidad
  from prdsalno
 where no_documento = _no_documento
   and liberar      = 0;

if _cantidad >= 1 then
	return 0, "Actualizacion Exitosa...";
end if

select count(*)
  into _cantidad
  from emipouni
 where no_poliza = a_no_poliza 
   and activo = 1;	   --> Le agregue esta condicion Amado 2/8/2011 

if _cantidad > 1 then
	return 0, "Actualizacion Exitosa...";
end if

LET _ano_contable = YEAR(today);

IF MONTH(today) < 10 THEN
	LET _mes_contable = '0' || MONTH(today);
ELSE
	LET _mes_contable = MONTH(today);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

return 1,_periodo;

end
return 0, "Actualizacion Exitosa...";
end procedure