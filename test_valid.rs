// A simple valid Rust program

fn main() {
    let x: i32 = 10;
    let mut y: i32 = 5;
    
    if x > y {
        println!("x is greater than y");
    } else {
        println!("x is not greater than y");
    }
    
    while y < x {
        y = y + 1;
        println!("y is now {}", y);
    }
    
    // Improved for loop with range
    for i in 0..5 {
        println!("Loop iteration {}", i);
    }
    
    // Function call demonstration
    let result: i32 = add(x, y);
    println!("Sum is {}", result);
    
    // Additional boolean operations
    let is_equal: bool = x == y;
    if is_equal {
        println!("x and y are equal");
    }
    
    // Nested if-else demonstration
    if x > 5 {
        if y > 5 {
            println!("Both x and y are greater than 5");
        } else {
            println!("Only x is greater than 5");
        }
    }
}

fn add(a: i32, b: i32) -> i32 {
    let sum: i32 = a + b;
    return sum;
}

// Additional function with multiple operations
fn calculate(a: i32, b: i32) -> i32 {
    let temp: i32 = a * 2;
    let result: i32 = temp + b / 2;
    return result;
}
