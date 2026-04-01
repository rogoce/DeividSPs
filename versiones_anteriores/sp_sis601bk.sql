-- polizas vigentes Manzanas distribucion
-- Creado: 01/09/2020 - Autor: Henry Giron

drop procedure sp_sis601;

create procedure "informix".sp_sis601(a_cod_manzana char(15), a_poliza char(20) default '*')
returning smallint, varchar(250);
{
 returning  char(3),		--cobertura
			char(5),		--contrato
			decimal(16,2),	--suma
			decimal(16,2),	--prima
			char(50),		--no_documento
			char(50);		--no_documento
}
define _no_poliza		  char(10);
define v_prima1	      	  dec(16,2);
define _no_unidad		  char(5);
define _suma_asegurada    dec(16,2);
define _actualizado       smallint;
define v_desc_contrato    char(50);
define v_cod_contrato     char(5);
define v_cobertura		  char(3);
define _nombre_cob        char(50);
define _tipo_contrato     char(1);
define _max_retencion     decimal(16,2);
define _max_suma_asegurada     decimal(16,2);
define _mensaje           varchar(250);
define _flag	      smallint;
define _suma_ret		  dec(16,2);
let _suma_ret       = 0;
SET ISOLATION TO DIRTY READ;

let _suma_asegurada = 0;
let v_prima1        = 0;
 drop table if exists temp_sis601;
 CREATE TEMP TABLE temp_sis601
           (cod_contrato     CHAR(5),
			desc_contrato    CHAR(50),
            cod_cobertura    CHAR(3),
			prima            DEC(16,2),
			suma             DEC(16,2)) WITH NO LOG;
			
 select trim(valor_parametro) 
  into _max_retencion
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion	= 'PRO'
   and version		= '02'
   and codigo_parametro	= 'max_ret_manzana';
   
 select trim(valor_parametro) 
  into _max_suma_asegurada
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion	= 'PRO'
   and version		= '02'
   and codigo_parametro	= 'max_suma_manzana';
if a_poliza = '*' then

FOREACH WITH HOLD

   select no_unidad,
          no_poliza,
		  suma_asegurada
     into _no_unidad,
		  _no_poliza,
		  _suma_asegurada
	 from emipouni
	where cod_manzana MATCHES a_cod_manzana
	order by no_poliza, no_unidad

   select actualizado
     into _actualizado
     from emipomae
    where no_poliza = _no_poliza;

   if _actualizado = 0 then
	continue foreach;
   end if	

	FOREACH
	    SELECT cod_cober_reas,
	    	   cod_contrato,
	    	   prima,
			   suma_asegurada
          INTO v_cobertura,
          	   v_cod_contrato,
          	   v_prima1,
			   _suma_asegurada
          FROM emifacon
         WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
           AND no_endoso = '00000'
           AND prima <> 0

		SELECT nombre,tipo_contrato
          INTO v_desc_contrato,_tipo_contrato
          FROM reacomae
         WHERE cod_contrato = v_cod_contrato;
		 
		 if _tipo_contrato <> 1 then
		    continue foreach;
		 end if		 

		INSERT INTO temp_sis601
              VALUES(v_cod_contrato,
					 v_desc_contrato,
                     v_cobertura,
                     v_prima1,
                     _suma_asegurada);

	END FOREACH

END FOREACH
{
foreach
	   select cod_cobertura,
	          cod_contrato,
			  suma,
			  prima,
			  desc_contrato
	     into v_cobertura,
			  v_cod_contrato,
			  _suma_asegurada,
			  v_prima1,
			  v_desc_contrato
		 from temp_sis601
		order by 1,2

         SELECT nombre
           INTO _nombre_cob
           FROM reacobre
          WHERE cod_cober_reas = v_cobertura;

	   RETURN v_cobertura, v_cod_contrato, _suma_asegurada, v_prima1, _nombre_cob, v_desc_contrato WITH RESUME;

end foreach
}

else
let _no_poliza = sp_sis21(a_poliza);
end if


--Parámetro para el mensaje de Advertencia (por superar o superado los 500k)
let _suma_ret = 0;
let _flag = 0;
let _mensaje = '';
select sum(suma)
	into _suma_ret
	from temp_sis601	
   where cod_manzana = a_cod_manzana
   and no_unidad = a_no_unidad;
   
  -- let _suma_ret = _suma_ret + a_suma_asegurada;
   
if _suma_ret > _max_retencion then  
    let _flag = 1; 	
end if

let _suma_ret = 0;
if _flag = 0 then
	select sum(suma)
		into _suma_ret
		from temp_sis601	
	   where cod_manzana = a_cod_manzana;
	   
	 --  let _suma_ret = _suma_ret + a_suma_asegurada;
	if _suma_ret > _max_retencion then 
		let _flag = 2; 
	end if
end if

if _flag = 1 then
	let _mensaje = 'SUMA ASEGURADA EXCEDE LOS B/. 500,000.00 DE RETENCION. FAVOR VERIFIQUE.';
end if
if _flag = 2 then
	let _mensaje = 'MANZANA SELECCIONADA SUPERA EL TOPE DEL CONTRATO DE RETENCION B/. 500,000.00. FAVOR VERIFIQUE.';
end if

return _flag,_mensaje;

DROP TABLE temp_sis601;
end procedure