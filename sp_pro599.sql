----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------
--execute procedure sp_pro382('001','001','2016-02','2016-02')

drop procedure sp_pro599;
create procedure sp_pro599(
a_periodo1			char(7),
a_periodo2			char(7)
)
returning 	char(7)		as Periodo,
			char(10) 	as No_Poliza,
			char(5)		as No_Endosos,
			char(20)	as No_Documento,
			char(5)		as No_Unidad,
			char(30)	as No_Motor,
			varchar(10)	as Uso_Auto,
			char(5)		as Cod_Cobertura,
			varchar(50)	as Cobertura,
			dec(16,2)	as Prima_Neta,
			char(5)		as Cod_Producto,
			varchar(50)	as Producto;
			
			

define _nom_producto				varchar(50);
define _nom_uso_auto				varchar(10);
define _no_motor					char(30);
define _no_documento				char(20);
define _periodo						char(7);
define _cod_producto				char(5);
define _no_unidad					char(5);
define _uso_auto					char(1);
define _null						char(1);
define _prima						dec(16,2);
define _error_isam					integer;
define _renglon						integer;
define _error						integer;
define _no_endoso                   char(5);
define _no_poliza                   char(10);
define _prima_neta                  dec(16,2);
define _cod_cobertura				char(5);
define _cobertura                   varchar(50);
define _error_desc					varchar(50);                 


set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	--let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
	--return _error,_error_desc;
end exception

--set debug file to "sp_pro382.trc";
--trace on;

foreach
	select a.periodo,
		   a.no_poliza,
		   a.no_endoso,
	       a.no_documento
	  into _periodo,
	       _no_poliza,
		   _no_endoso,
	       _no_documento
	  from endedmae a, emipomae b
	 where a.no_poliza = b.no_poliza
	   and a.periodo >= a_periodo1 
	   and a.periodo <= a_periodo2 
	   and b.cod_ramo = '020'
	   and a.actualizado = 1
	 order by a.periodo, a.no_documento

	 
	foreach 
		select no_unidad,
			   cod_producto
		  into _no_unidad,
			   _cod_producto
		  from endeduni 
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select nombre
		  into _nom_producto
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		let _no_motor = null; 
		 
		select no_motor,
		       uso_auto
          into _no_motor,
		       _uso_auto
          from emiauto	
         where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
 
        if trim(_no_motor) = "" or _no_motor is null then
			select no_motor,
			       uso_auto
			  into _no_motor,
			       _uso_auto
			  from endmoaut	
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and no_endoso = _no_endoso;
		end if	  

		if _uso_auto = 'P' then
			let _nom_uso_auto = 'PARTICULAR';
		elif _uso_auto = 'C' then
			let _nom_uso_auto = 'COMERCIAL';
		else
			let _nom_uso_auto = _uso_auto;
		end if	

        let _prima_neta = 0.00;		
		
		foreach
			select cod_cobertura,
			       prima_neta
			  into _cod_cobertura,
			       _prima_neta
			  from endedcob
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad
			   and cod_cobertura in ('01021','01022')
			   
			select nombre 
              into _cobertura
              from prdcober
             where cod_cobertura = _cod_cobertura;			  
   	
            return _periodo,
			       _no_poliza,
				   _no_endoso,
				   _no_documento,
				   _no_unidad,
				   _no_motor,
				   _nom_uso_auto,
				   _cod_cobertura,
				   _cobertura,
				   _prima_neta,
				   _cod_producto,
				   _nom_producto with resume;
		end foreach		   
	end foreach
end foreach
end
end procedure;