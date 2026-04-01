drop procedure sp_par350; 

create procedure "informix".sp_par350()
returning integer,
          char(30),
		  char(50),
		  char(13),
		  date;

define _no_documento	char(50);
define _no_poliza		char(10);

define _docno			integer;
define _cedula			char(30);
define _fecha			date;
define _id				integer;

foreach
 select numero_de_poliza,
		docno,
		numero_de_identifi,
		fecha,
		id
   into _no_documento,
        _docno,
		_cedula,
		_fecha,
		_id
   from deivid_tmp:tmp_therefore

	let _no_poliza = sp_sis21(_no_documento);  

	if _no_poliza is null then

		{
		let _no_poliza = sp_sis21(_no_documento[1,13]);  
		
		if _no_poliza is not null then

			update deivid_tmp:tmp_therefore
			   set numero_de_poliza = _no_documento[1,13]
			 where id = _id;

		end if
		--}

		return _docno,
		       _cedula,
			   _no_documento,
			   _no_documento[1,13],
			   _fecha
			   with resume;

	end if

end foreach

end procedure
