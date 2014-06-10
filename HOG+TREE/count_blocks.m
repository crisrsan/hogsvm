    ped_ratio=0.5;
    rect =0;
    r=0; c=0;
    if(rect)
        block_ratio = [0.5 1 2]; % block width/height
    else
        block_ratio = 2;
    end
    h = 128;
    w = h*ped_ratio;  
    
    for i=1:length(block_ratio)    

        region = zeros(1,4);
        region(1,4)=block_ratio(i);
 
        switch (region(1,4))
            case 1
                block_size = 12:2:64;
       
            case 0.5
                block_size = 12:2:128;
                   
            case 2
                block_size = 12:2:32;
        end
        for j=1:length(block_size)
            
            region(1,3)=block_size(j);

            row_pos=1:2:(h-region(1,3)+1);

            r(j)=length(row_pos);
            col_pos=1:2:(w-(region(1,3)*region(1,4))+1);
   
            c(j)=length(col_pos);
        end
    end