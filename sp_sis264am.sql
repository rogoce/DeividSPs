-- Procedure para determinar la prima cedida para vida
-- Armando Moreno M. 03/12/2024


drop procedure sp_sis264am;
create procedure sp_sis264am(a_no_poliza char(10))
returning integer,varchar(150),dec(16,2);


define _cod_asegurado char(10);
define _sexo		  char(1);
define _fecha_aniv,_vigencia_inic,_vigencia_final    date;
define _error,_edad	  integer;
define _porcentaje,_fumador    smallint;
define _no_unidad     char(5);
define _desc_error    varchar(150);
define _prima_cedida, _prima_retenida,_h_no_fumador,_h_fumador dec(16,2);
define _m_no_fumador, _m_fumador dec(16,2);

begin

let _error          = 0;
let _prima_cedida   = 0.00;
let _prima_retenida = 0.00;
let _desc_error     = "";

select porcentaje_vida
  into _porcentaje
  from parparam;
  
select vigencia_inic
  into _vigencia_inic
  from emipomae
 where no_poliza = a_no_poliza;
	 
foreach
	select cod_asegurado,
	       no_unidad
	  into _cod_asegurado,
	       _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza 
  	
	select fecha_aniversario,
	       sexo,
		   fumador
      into _fecha_aniv,
	       _sexo,
		   _fumador
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	if _fecha_aniv is null then
		let _error = 336;
		exit foreach;
	end if
	if trim(_sexo) not in('F','M') then
		let _error = 338;
	end if

	let _edad = sp_sis78(_fecha_aniv,_vigencia_inic);
	
	if _edad >= 0 and _edad <= 120 then
		select h_no_fumador,
		       h_fumador,
			   m_no_fumador,
			   m_fumador
		  into _h_no_fumador,
               _h_fumador,
			   _m_no_fumador,
			   _m_fumador
		  from riesgo_vida	   
		 where edad = _edad;
		 
		if _sexo = 'M' then			--es hombre
			if _fumador = 1 then	--es fumador
			    let _h_fumador = _h_fumador * _porcentaje / 100;
				return _error,_desc_error,_h_fumador;
			else
			    let _h_no_fumador = _h_no_fumador * _porcentaje / 100;
				return _error,_desc_error,_h_no_fumador;
			end if
		elif _sexo = 'F' then			--es Mujer
			if _fumador = 1 then	--es fumador
			    let _m_fumador = _m_fumador * _porcentaje / 100;
				return _error,_desc_error,_m_fumador;
			else
			    let _m_no_fumador = _m_no_fumador * _porcentaje / 100;			
				return _error,_desc_error,_m_no_fumador;
			end if
		end if
	else
		let _error = 337;
	end if
	
end foreach
if _error <> 0 then
	select descripcion
	  into _desc_error
	  from inserror
	 where tipo_error = 2
       and code_error = _error;
end if
end 
return _error,_desc_error,0;
end procedure