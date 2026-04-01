-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

drop procedure sp_pro30cc;

create procedure sp_pro30cc(a_no_poliza char(10))
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
DEFINE _periodo           CHAR(7);
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

set debug file to "sp_pro30cc.trc";
trace on;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Cambiar Tarifas...";
end exception

let _fecha_a = current;
let _anno    = year(_fecha_a);
LET v_fecha_r = current;


select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

LET _ano_contable = YEAR(today);

IF MONTH(today) < 10 THEN
	LET _mes_contable = '0' || MONTH(today);
ELSE
	LET _mes_contable = MONTH(today);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

foreach
 select cod_asegurado,
        cod_producto,
		prima_asegurado,
		no_unidad,
		cambiar_tarifas
   into _cod_cliente, 
        _cod_producto, 
		_prima_total, 
		_no_unidad,
		_cambiar_tarifas
   from emipouni
  where no_poliza = a_no_poliza
    and activo    = 1		 --> Le agregue esta condicion Amado 2/8/2011

	let _producto_nuevo = _cod_producto;

	select vigencia_inic,
	       vigencia_final,
		   cod_perpago,
		   cod_tipoprod,
		   no_documento,
		   cod_subramo,
		   cod_grupo
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_perpago,
		   _cod_tipoprod,
		   _no_documento,
		   _cod_subramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = a_no_poliza; 

    let _cod_producto = '01743';

    select tar_salud
	  into _tar_salud
	  from prdprod
	 where cod_producto = _cod_producto;

	
    let _tarifa_dep_tot	= 0;
   	let _prima_plan = 0;  

    if _tar_salud = 5 then	--> Tarifas por edad (Aseg + Dep)

      FOREACH with hold
		SELECT cod_cliente
		  INTO _cod_depend
		  FROM emidepen
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1

		SELECT fecha_aniversario
		  INTO _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_depend;
--		trace off;
        LET _edad = sp_sis78(_fecha_aniversario);
--		trace on;
        let _tarifa_dep = 0;
        let _prima_plan_dep = 0;
        let _prima_vida_dep = 0;
         
		select prima, prima_vida
		  into _prima_plan_dep, _prima_vida_dep
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		if _prima_plan_dep is null then
			let _prima_plan_dep = 0;
		end if

		if _prima_vida_dep is null then
			let _prima_vida_dep = 0;
		end if

        let _tarifa_dep = _prima_plan_dep + _prima_vida_dep;

        UPDATE emidepen 
		   SET prima = _tarifa_dep,
		       calcula_prima = 1
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad
		   AND cod_cliente = _cod_depend
		   AND activo = 1;

		let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;

	  END FOREACH
	  
	  let _prima_plan = _prima_plan + _tarifa_dep_tot; 

    end if


-- Hasta Aqui las evaluaciones.

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		If _cod_perpago = '008' then  --Anual
			let _meses = 12;
		else
			let _meses = 1;
		End if
	end if

	-- Porcentaje de Impuesto
	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_no_poliza;

	IF _porc_impuesto IS NULL THEN
		LET _porc_impuesto = 0;
	END IF

	let _porc_impuesto = _porc_impuesto / 100;

	-- Porcentaje de Descuento

	LET _porc_descuento = 0;

	SELECT SUM(porc_descuento)
	  INTO _porc_descuento
	  FROM emiunide
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_descuento IS NULL THEN
		LET _porc_descuento = 0;
	END IF

	-- Porcentaje de Recargo

	LET _porc_recargo   = 0;

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiunire
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_recargo IS NULL THEN
		LET _porc_recargo = 0;
	END IF


	set lock mode to wait; --> para que espere y no tranque la BD Amado 4/10/2010
	let _prima = 0;
	let	_descuento = 0;
	let	_recargo   = 0;
	let	_prima_neta = 0;
	let	_impuesto   = 0;
	let	_prima_bruta  = 0;
	let _prima_vida = 0;
	let _prima_suscrita = 0;
	update emipouni
	   set cod_producto 	= _cod_producto,
	       prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   impuesto			= _impuesto,
		   prima_bruta 		= _prima_bruta,
		   prima_asegurado	= _prima_plan + _prima_vida,
		   prima_total		= _prima,
		   prima_suscrita   = _prima_suscrita
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad;

	 if _cod_producto = _producto_nuevo then --No hubo cambio de producto
	 else

		delete from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		let _desc_limite1 = null;
		let _desc_limite2 = null;
		let _ded_n        = "";

		 foreach			--Actualizar los beneficios del producto en los campos de la cobertura, Armando 27/08/2012

			select cod_cobertura,
			       desc_limite1,
			       desc_limite2,
				   orden,
				   deducible
			  into _cod_cober,
			       _desc_limite1,
			       _desc_limite2,
				   _orden_n,
				   _ded_nn
			  from prdcobpd
			 where cod_producto  = _cod_producto
			   and cob_requerida = 1

			if _ded_nn is null then
				let _ded_nn = 0;
			end if
			let _ded_n = _ded_nn;

			let _prima_nn = 0;
            if _orden_n = 1 then
				let _prima_nn = 1;
			end if
			 
			insert into emipocob(
				   no_poliza,
				   no_unidad,
				   cod_cobertura,
				   orden,
				   tarifa,			
				   deducible,
				   limite_1,		
				   limite_2,		
				   prima_anual,		
				   prima,			
				   descuento,
				   recargo,			
				   prima_neta,		
				   date_added,		
				   date_changed,	
				   factor_vigencia,
				   desc_limite1,	
				   desc_limite2
				   )	
			       values (
			        a_no_poliza,
			        _no_unidad,
			        _cod_cober,
			        _orden_n,
			        0,
			        _ded_n,
			        0,     		 							
			        0,
			        _prima_nn,
			        0,	 	 							
			        0,	 		 							
			        0,
					0,
					v_fecha_r,
					v_fecha_r,
					1,
					_desc_limite1,
					_desc_limite2
					);

		 end foreach
	 end if

	update emipocob
	   set prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   prima_anual		= _prima
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad
	   and prima_anual      <> 0.00;

	-- Realiza el cambio automatico de la nueva prima

	-- En caso de que sean Tarjetas de Credito 

	update cobtacre
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;      	

	-- En caso de que sean ACH 

	update cobcutas
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;
	 
	set isolation to dirty read; --> cambiamos a dirty read para que no tranque Amado 4/10/2010      	

end foreach

end

return 0, "Actualizacion Exitosa...";

end procedure