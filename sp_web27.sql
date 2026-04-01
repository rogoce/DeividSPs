-- Creacion de las letras de pago de las polizas por nueva ley de seguros

-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_web27;

create procedure sp_web27(
a_no_poliza	char(10)
) returning	smallint,
			date,
			date,
			dec(16,2),
			smallint,
			date,
			date,
			dec(16,2);

define _letra			smallint;
define _fecha_pago		date;
define _periodo_gracia	date;
define _monto_letra		dec(16,2);
define _letra2			smallint;
define _fecha_pago2		date;
define _periodo_gracia2	date;
define _monto_letra2	dec(16,2);
define _cnt				smallint;
define _fila          	smallint;

create temp table tmp_letra(
       fila            smallint,
       letra1          smallint,
       fecha_pago1     date, 
	   periodo_gracia1 date,
	   monto_letra1    dec(16,2),
       letra2          smallint default 0,
       fecha_pago2     date default null, 
	   periodo_gracia2 date default null,
	   monto_letra2    dec(16,2) default 0,
	   PRIMARY KEY (fila)
	   ) WITH NO LOG;

set isolation to dirty read;

let _cnt = 1;
let _fila = 1;

foreach
	select no_letra,
	       fecha_vencimiento,
		   periodo_gracia,
		   monto_letra
	  into _letra,
		   _fecha_pago,
		   _periodo_gracia,
		   _monto_letra
	  from emiletra
	 where no_poliza = a_no_poliza

	 if _cnt < 7 then
	    insert into tmp_letra(
		   fila,
		   letra1,         
		   fecha_pago1,    
		   periodo_gracia1,
		   monto_letra1)
		 values (
		   _fila,
		   _letra,
		   _fecha_pago,
		   _periodo_gracia,
		   _monto_letra);

	  	let _fila = _fila + 1;
	  else
	  	let _fila = _cnt - 6;

	     update tmp_letra
		    set letra2          =  _letra,       
				fecha_pago2    	=  _fecha_pago,
				periodo_gracia2	=  _periodo_gracia,
				monto_letra2   	=  _monto_letra
		  where fila = _fila;

      end if
      
      let _cnt = _cnt + 1;    

end foreach

foreach	with hold
	 select letra1,         
	 		fecha_pago1,    
	 		periodo_gracia1,
	 		monto_letra1,   
	 		letra2,         
	  		fecha_pago2,    
			periodo_gracia2,
			monto_letra2 
	   into _letra,			
	   		_fecha_pago,		
	   		_periodo_gracia,	
	   		_monto_letra,		
	   		_letra2,			
	   		_fecha_pago2,		
	   		_periodo_gracia2,
	   		_monto_letra2	
	   from tmp_letra
	  order by fila 		  

     return _letra,
			_fecha_pago,
			_periodo_gracia,
			_monto_letra, 
			_letra2,			
			_fecha_pago2,		
			_periodo_gracia2,
			_monto_letra2	with resume;
end foreach

DROP TABLE tmp_letra;

end procedure