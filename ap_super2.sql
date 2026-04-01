------------------------------------------------
--   Detalle de Autoriza Cheque          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure ap_super2;
create procedure ap_super2()
			
returning	char(10) as cod_contratante,
			varchar(100) as contratante,
			varchar(30) as cedula,
			char(1) as tipo_persona,
			char(20) as poliza,
			char(10)  as remesa,
			dec(16,2) as importe;

define _importe      dec(16,2); 
define _tipo_persona    char(1); 
define _cod_contratante char(10);
define _no_documento    char(20);
define _contratante     varchar(100);
define _cedula          varchar(30);
define _no_poliza       char(10);
define _no_remesa       char(10);
			
begin


	--set debug file to "sp_che149.trc";
	--trace on;

set isolation to dirty read;	
--drop table temp_perfil;

foreach with hold
	select a.no_remesa,
	       a.no_poliza,
		   a.doc_remesa,
		   b.importe
	  into _no_remesa,
	       _no_poliza,
	       _no_documento,
		   _importe
	  from cobredet a, cobrepag b
	 where a.no_remesa = b.no_remesa
	   and a.renglon = b.renglon
	   and a.fecha >= '01/01/2016'
	   and a.fecha <= '31/10/2016'
	   and a.tipo_mov = 'P'
	   and b.tipo_pago = 1
	   
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
			_no_remesa,
			_importe with resume;
	  
end foreach
   

end

end procedure  

 
		