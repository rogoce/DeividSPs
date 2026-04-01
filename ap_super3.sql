------------------------------------------------
--   Detalle de Autoriza Cheque          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure ap_super3;
create procedure ap_super3()
			
returning	char(10) as cod_contratante,
			varchar(100) as contratante,
			varchar(30) as cedula,
			char(1) as tipo_persona,
			char(20) as poliza,
			dec(16,2) as monto;

define _prima_neta      dec(16,2); 
define _tipo_persona    char(1); 
define _cod_contratante char(10);
define _no_documento    char(20);
define _contratante     varchar(100);
define _cedula          varchar(30);
define _no_poliza       char(10);
define _no_remesa       char(10);
define _cod_tipocan     char(3);
define _prima_neta2     dec(16,2); 

create temp table tmp_cancela(
no_poliza       char(20),
cod_contratante char(10),
no_documento    char(20),
prima_neta      dec(16,2)) with no log;
create index i_perfil1 on tmp_cancela(no_poliza);
create index i_perfil2 on tmp_cancela(cod_contratante);

			
begin


	--set debug file to "sp_che149.trc";
	--trace on;

set isolation to dirty read;	
--drop table temp_perfil;

foreach 
	   
	select b.no_documento,
	       b.prima_neta
	  into _no_documento,
	       _prima_neta
	  from chqchmae a, chqchpol b
	 where a.no_requis = b.no_requis
	   and a.fecha_impresion >= '01/01/2016'
	   and a.fecha_impresion <= '31/10/2016'
	   and a.anulado = 0
	   
	if  _prima_neta > 10000 then
	    let _no_poliza = sp_sis21(_no_documento);
		
		select cod_contratante
		  into _cod_contratante
		  from emipomae
		 where no_poliza = _no_poliza;
		   
		 select nombre, 
				cedula,
				tipo_persona			
		   into _contratante,
				_cedula,
				_tipo_persona
		   from cliclien
		  where cod_cliente = _cod_contratante;
	   
			  
			 return _cod_contratante,
					_contratante,
					_cedula,
					_tipo_persona,
					_no_documento,
					_prima_neta with resume;
	end if
end foreach

drop table tmp_cancela;
end

end procedure  

 
		