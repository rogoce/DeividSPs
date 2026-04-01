
-- Creado: 28/09/2023 - Autor: Amado Perez Mendoza: Requerimiento solicitado por Armando

drop procedure sp_che253;

create procedure sp_che253(a_periodo char(7))
returning  char(3) as CodVendedor,
           varchar(50) as Vendedor, 
		   char(5) as CodCorredor,
           varchar(50) as Corredor,
		   char(5) as CodCorredor2,
           varchar(50) as Corredor2,
		   char(3) as CodRamo,
           varchar(50) as Ramo,
		   char(3) as CodSubramo,
           varchar(50) as Subramo,
		   char(20) as Poliza,
		   date as VigenciaInicial,
		   date as VigenciaFinal,
		   dec(16,2) as MontoCobrado,
		   dec(16,2) as MontoNetoCobrado,
		   dec(5,2) as PorcComision,
		   dec(16,2) as Comision,
		   dec(16,2) as BonoCobranzaAA,
		   dec(16,2) as Bono1Web,
		   dec(16,2) as BonoRentabilidadAP,
		   dec(16,2) as BonoRentabilidadAA,
		   dec(16,2) as BonoRamosGeneralesAP,
		   dec(16,2) as BonoRamosGeneralesAA,
		   dec(16,2) as BonoVidaAA,
		   dec(16,2) as BonoPersistenciaAP;	
		   
define _cod_agente   	char(5);
define _no_requis   	char(10);
define _agente    	    varchar(50);
define _cod_vendedor    char(3);
define _vendedor    	varchar(50);
define _cod_agente2   	char(5);
define _agente2    	    varchar(50);
define _no_poliza 		char(10);
define _no_documento 	char(20);
define _monto			dec(16,2);
define _prima			dec(16,2);
define _porc_comis		dec(5,2);
define _comision		dec(16,2);
define _cod_ramo     	char(3);
define _cod_subramo		char(3);
define _vigencia_inic	date;
define _vigencia_final  date;
define _ramo    		varchar(50);
define _subramo    		varchar(50);

define _error           integer;

let _error = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf103.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	--RETURN null, null, null, null, _error, null; 
END EXCEPTION         

FOREACH  
	select cod_agente, 
	       no_requis
      into _cod_agente,
           _no_requis		   
	  from chqchmae 
	 where periodo >= a_periodo
	   and origen_cheque = '2' 
	   and pagado = 1 
	   and anulado = 0
	order by cod_agente
	
	select nombre,
	       cod_vendedor
	  into _agente,
	       _cod_vendedor	   
	  from agtagent
     where cod_agente = _cod_agente;

    select nombre
      into _vendedor
      from agtvende
     where cod_vendedor = _cod_vendedor;	

    call sp_che168(_cod_agente) returning _error, _cod_agente2;

	select nombre
	  into _agente2	   
	  from agtagent
     where cod_agente = _cod_agente2;
	
	foreach
		select no_poliza,
		       no_documento,
			   monto,
			   prima,
			   porc_comis,
			   comision
		  into _no_poliza,
		       _no_documento,
			   _monto,
			   _prima,
			   _porc_comis,
			   _comision
		  from chqcomis
		 where no_requis = _no_requis

		select cod_ramo,
		       cod_subramo,
			   vigencia_inic,
			   vigencia_final
		  into _cod_ramo,
               _cod_subramo,
			   _vigencia_inic,
			   _vigencia_final
          from emipomae	
         where no_poliza = _no_poliza;		  
		
		select nombre 
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
		 
		select nombre 
		  into _subramo
		  from prdsubra
		 where cod_ramo = _cod_ramo
		   and cod_subramo = _cod_subramo;
		   
		if _no_poliza = '00000' then
			let _no_documento = 'COMISION DESCONTADA';
        end if		
 
		return _cod_vendedor,
		       _vendedor,
			   _cod_agente,
			   _agente,
			   _cod_agente2,
			   _agente2,
			   _cod_ramo,
			   _ramo,
			   _cod_subramo,
			   _subramo,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _monto,
			   _prima,
			   _porc_comis,
			   _comision,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00 with resume;
	end foreach
end foreach	
end

end procedure
