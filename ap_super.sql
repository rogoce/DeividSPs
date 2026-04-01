------------------------------------------------
--   Detalle de Autoriza Cheque          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure ap_super;
create procedure ap_super()
			
returning	char(10) as cod_contratante,
			varchar(100) as contratante,
			varchar(30) as cedula,
			char(1) as tipo_persona,
			char(20) as poliza,
			dec(16,2) as prima_neta;

define v_filtros        varchar(255);
define _prima_neta      dec(16,2); 
define _tipo_persona    char(1); 
define _cod_contratante char(10);
define _no_documento    char(20);
define _contratante     varchar(100);
define _cedula          varchar(30);
			
begin


	--set debug file to "sp_che149.trc";
	--trace on;

set isolation to dirty read;	
--drop table temp_perfil;
call ap_pro03('001','001','31/10/2016','*') returning v_filtros;

foreach with hold
	select sum(prima_neta),
	       cod_contratante,
	       tipo_persona
	  into _prima_neta,
	       _cod_contratante,
	       _tipo_persona
	  from temp_perfil
	group by cod_contratante, tipo_persona 
	
    if 	(_prima_neta >= 10000 and _tipo_persona = 'N') or (_prima_neta >= 50000 and _tipo_persona = 'J') then
		foreach with hold
			select no_documento,
			       prima_neta
			  into _no_documento,
			       _prima_neta
			  from temp_perfil
			 where cod_contratante = _cod_contratante
			 
			 select nombre, 
                    cedula			 
			   into _contratante,
			        _cedula
			   from cliclien
			  where cod_cliente = _cod_contratante;
			 
			 return _cod_contratante,
			        _contratante,
					_cedula,
					_tipo_persona,
					_no_documento,
					_prima_neta with resume;
		end foreach
	end if
	  
end foreach
   
drop table temp_perfil;
end

end procedure  

 
		